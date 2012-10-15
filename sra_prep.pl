#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long;
use Pod::Usage;
use YAML qw(Dump Load DumpFile LoadFile);

use Text::CSV_XS;
use File::Basename;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
my $yml_file;
my $platform_rx;
my $layout_rx;

my $man  = 0;
my $help = 0;

GetOptions(
    'help|?'       => \$help,
    'man'          => \$man,
    'y|yml=s'      => \$yml_file,
    'p|platform=s' => \$platform_rx,
    'l|layout=s'   => \$layout_rx,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $yml = LoadFile($yml_file);
my $basename = basename( $yml_file, ".yml", ".yaml" );
$basename .= ".$platform_rx" if $platform_rx;
$basename .= ".$layout_rx"   if $layout_rx;

my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
$csv->eol("\n");

open my $csv_fh, ">", "$basename.csv";
open my $ftp_fh, ">", "$basename.ftp.txt";

$csv->print( $csv_fh, [qw{ name srx platform layout srr spot base }] );
for my $name ( sort keys %{$yml} ) {
    print "$name\n";

    for my $srx ( sort keys %{ $yml->{$name} } ) {
        my $info = $yml->{$name}{$srx};
        print " " x 4, "$srx\n";

        my $platform = $info->{platform};
        my $layout   = $info->{layout};
        print " " x 8, $platform, " " x 8, $layout, "\n";

        if ($platform_rx) {
            next unless $platform =~ qr/$platform_rx/i;
        }
        if ($layout_rx) {
            next unless $layout =~ qr/$layout_rx/i;
        }

        for my $i ( 0 .. scalar @{ $info->{srr} } - 1 ) {
            my $srr = $info->{srr}[$i];
            my $url = $info->{downloads}[$i];

            my $spot = $info->{srr_info}{$srr}{spot};
            my $base = $info->{srr_info}{$srr}{base};

            $csv->print( $csv_fh,
                [ $name, $srx, $platform, $layout, $srr, $spot, $base, ] );
            print {$ftp_fh} $url, "\n";
        }
    }
}

close $ftp_fh;
close $csv_fh;

__END__

=head1 NAME

    sra_prep.pl - prepare for sra

=head1 SYNOPSIS

    perl sra_prep.pl -y dpgp.yml -p illumina -l pair

    sra_stat.pl [options]
      Options:
        --help              brief help message
        --man               full documentation
        -y, --yml           yaml file of sra info
        -p, --platform      illumina or 454
        -l, --layout        pair or single

    Two files will be generated, dpgp.csv and dpgp.ftp.txt

    You can edit the generated csv file for custom filters.
    And don't forget to rename the modified csv.

    dpgp.ftp.txt containg all sra files' ftp url.
    aria2c -x 12 -s 4 -i dpgp.ftp.txt
