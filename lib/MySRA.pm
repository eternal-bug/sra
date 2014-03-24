package MySRA;
use Moose;
use Carp;

use WWW::Mechanize;
use Regexp::Common qw(balanced);
use List::MoreUtils qw(uniq zip);
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use HTML::TableExtract;

use YAML qw(Dump Load DumpFile LoadFile);

has 'proxy' => ( is => 'rw', isa => 'Str', );

sub BUILD {
    my $self = shift;

    return;
}

sub srp_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part1 = "http://www.ncbi.nlm.nih.gov/sra?term=";
    my $url_part2 = "&from=begin&to=end&dispmax=200";
    my $url       = $url_part1 . $term . $url_part2;
    print $url, "\n";

    my @srx;

    $mech->get($url);

    my @links = $mech->find_all_links( url_regex => => qr{sra\/[DES]RX\d+}, );

    printf "OK, get %d SRX\n", scalar @links;
    @srx = map { /sra\/([DES]RX\d+)/; $1 } map { $_->url } @links;

    return \@srx;
}

sub srs_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part1 = "http://www.ncbi.nlm.nih.gov/biosample/?term=";
    my $url_part2 = "&from=begin&to=end&dispmax=200";
    my $url       = $url_part1 . $term . $url_part2;
    print $url, "\n";

    my @srx;

    $mech->get($url);

    # this link exists in both summary and detailed pages
    $mech->follow_link(
        text_regex => qr{[DES]RS\d+},
        url_regex  => => qr{sample},
    );

    {
        my @links = $mech->find_all_links(
            text_regex => qr{[DES]RX\d+},
            url_regex  => qr{report},
        );

        printf "OK, get %d SRX\n", scalar @links;
        @srx = map { $_->text } @links;
    }

    return \@srx;
}

sub srx_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part = "http://www.ncbi.nlm.nih.gov/sra?term=";
    my $url      = $url_part . $term;
    print $url, "\n";

    my $info = {
        sample   => "",
        library  => "",
        platform => "",
        layout   => "",
    };

    $mech->get($url);

    my $page = $mech->content;
    my $te   = HTML::TableExtract->new;
    $te->parse($page);

    my %srr_info;
    for my $ts ( $te->table_states ) {
        for my $row ( $ts->rows ) {
            for my $cell (@$row) {
                $cell =~ s/,//g;
                $cell =~ s/\s+//g;
            }
            next unless $row->[0] =~ /\d+/;
            $srr_info{ $row->[1] } = { spot => $row->[2], base => $row->[3] };
        }
    }
    $info->{srr_info} = \%srr_info;

    {
        my @links = $mech->find_all_links( url_regex => => qr{ftp.*RX\/.RX}, );
        return unless scalar @links;
        $info->{ftp_base} = $links[0]->url;
        ( $info->{srx} ) = reverse grep {$_} split /\//, $info->{ftp_base};
    }

    {
        my ( @srr, @downloads );
        my @links = $mech->find_all_links( text_regex => qr{[DES]RR}, );
        printf "OK, get %d SRR\n", scalar @links;

        @srr       = map { $_->text } @links;
        @downloads = map { $info->{ftp_base} . "/$_/$_.sra" } @srr;

        $info->{srr}       = \@srr;
        $info->{downloads} = \@downloads;
    }

    {
        my @links = $mech->find_all_links(
            url_regex => qr{study},
        );
        ( $info->{srp} ) = reverse grep {$_} split /\=/, $links[0]->url;
    }

    {
        my @links = $mech->find_all_links(
            url_regex  => => qr{sample},
        );
        $info->{srs} = $links[0]->text;
    }

    {
        my $content = $mech->content;

        $content =~ s/^.+Accession\://s;
        $content =~ s/Download reads.+$//s;
        $content =~ s/$RE{balanced}{-parens=>'<>'}/ /g;
        $content =~ s/$RE{balanced}{-parens=>'()'}/\n/g;
        $content =~ s/ +/ /g;
        $content =~ s/\n+/\n/g;
        $content =~ s/\s{2,}/\n/g;
        my @lines = grep {$_} split /\n/, $content;

        while (@lines) {
            my $line = shift @lines;
            if ( $line =~ /(sample|library|platform)\:\s+(.+)$/i ) {
                $info->{ lc $1 } = $2;
            }
            if ( $line =~ /(Layout)\:\s+(\w+)/i ) {
                $info->{ lc $1 } = $2;
            }
            if ( $line =~ /(Strategy)\:\s+(\w+)/i ) {
                $info->{ lc $1 } = $2;
            }
            if ( $line =~ /(Source)\:\s+(\w+)/i ) {
                $info->{ lc $1 } = $2;
            }
            if ( $line =~ /(Selection)\:\s+(\w+)/i ) {
                $info->{ lc $1 } = $2;
            }
            if ( $line =~ /(Nominal length)\:\s+(\w+)/i ) {
                $info->{ lc $1 } = $2;
            }
        }
    }

    return $info;
}

sub wgs_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part = "http://www.ncbi.nlm.nih.gov/Traces/wgs/";
    my $url      = $url_part . '?val=' . $term;
    print $url, "\n";

    my $info = { prefix => $term, };
    $mech->get($url);

    {                         # extract from tables
        my $page    = $mech->content;
        my @tables  = qw{ meta-table structured-comments };
        my @columns = (
            '#_of_Contigs',    'Total_length',
            'Update_date',     'BioProject',
            'Keywords',        'Organism',
            'Assembly_Method', 'Assembly_Name',
            'Genome_Coverage', 'Sequencing_Technology',
        );

        for my $table (@tables) {
            print "Extract from table ", $table, "\n";
            my $te
                = HTML::TableExtract->new( attribs => { class => $table, }, );
            $te->parse($page);

            my %srr_info;
            for my $ts ( $te->table_states ) {
                for my $row ( $ts->rows ) {
                    for my $cell (@$row) {
                        if ($cell) {
                            $cell =~ s/[,:]//g;
                            $cell =~ s/^\s+//g;
                            $cell =~ s/\s+$//g;
                            $cell =~ s/\s+/ /g;
                        }
                    }
                    next unless $row->[0];
                    $row->[0] =~ s/\s+/_/g;
                    next unless grep { $row->[0] eq $_ } @columns;

                    $info->{ $row->[0] } = $row->[1];
                }
            }
        }
    }

    {    # taxon id
        my @links = $mech->find_all_links( url_regex => => qr{wwwtax}, );
        if ( @links and $links[0]->url =~ /\?id=(\d+)/ ) {
            $info->{taxon_id} = $1;
        }
    }

    {    # pubmed id
        my @links = $mech->find_all_links( url_regex => => qr{\/pubmed\/}, );
        if ( @links and $links[0]->url =~ /\/pubmed\/(\d+)/ ) {
            $info->{pubmed} = $1;
        }
    }

    {    # downloads
        my @links = $mech->find_all_links(
            text_regex => qr{$term},
            url_regex  => => qr{download=},
        );
        $info->{download} = [ map { $url_part . $_->url } @links ];
    }

    return $info;
}

1;
