#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use FindBin;
use YAML::Syck qw();

use AlignDB::IntSpan;
use App::RL::Common;
use App::Fasops::Common;
use Graph;
use Path::Tiny qw();

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
my $usage_desc = <<EOF;
LAshow outputs to ovelaps

Usage: perl %c [options] <fasta file> <LAshow outputs>
EOF

my @opt_spec = (
    [ 'help|h', 'display this message' ],
    [],
    [ 'replace|r=s', 'original names of sequences', ],
    { show_defaults => 1, },
);

( my Getopt::Long::Descriptive::Opts $opt, my Getopt::Long::Descriptive::Usage $usage, )
    = Getopt::Long::Descriptive::describe_options( $usage_desc, @opt_spec, );

$usage->die if $opt->{help};

if ( @ARGV != 2 ) {
    my $message = "This script need two input files.\n\tIt found";
    $message .= sprintf " [%s]", $_ for @ARGV;
    $message .= ".\n";
    $usage->die( { pre_text => $message } );
}
for (@ARGV) {
    next if lc $_ eq "stdin";
    if ( !Path::Tiny::path($_)->is_file ) {
        $usage->die( { pre_text => "The input file [$_] doesn't exist.\n" } );
    }
}

if ( $opt->{replace} ) {
    if ( !Path::Tiny::path( $opt->{replace} )->is_file ) {
        $usage->die( { pre_text => "The replace file [$opt->{replace}] doesn't exist.\n" } );
    }
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $len_of = get_len_from_header( $ARGV[0] );
print STDERR "Get @{[scalar keys %{$len_of}]} records of sequence length\n";

my $replace_of = {};
if ( $opt->{replace} ) {
    $replace_of = get_replaces( $opt->{replace} );
}

my $in_fh;
if ( lc $ARGV[1] eq 'stdin' ) {
    $in_fh = *STDIN{IO};
}
else {
    open $in_fh, "<", $ARGV[1];
}

while ( my $line = <$in_fh> ) {
    $line =~ s/,//g;
    $line =~ m{
        ^\D*
        (\d+)       # f
        \s+(\d+)    # g
        \s+(\w)     # orientation
        \D+(\d+)    # f.B
        \D+(\d+)    # f.E
        \D+(\d+)    # g.B
        \D+(\d+)    # g.E
        \D+([\d.]+) # identity
        .*$
    }x or next;

    my $f_id = $1;
    my $g_id = $2;

    next unless exists $len_of->{$f_id};
    next unless exists $len_of->{$g_id};

    my $g_ori    = $3 eq "n" ? 0 : 1;
    my $f_B      = $4;
    my $f_E      = $5;
    my $g_B      = $6;
    my $g_E      = $7;
    my $identity = ( 100 - $8 ) / 100;

    my $ovlp_len = $f_E - $f_B;

    printf "%s",   exists $replace_of->{$f_id} ? $replace_of->{$f_id}[0] : $f_id;
    printf "\t%s", exists $replace_of->{$g_id} ? $replace_of->{$g_id}[0] : $g_id;
    printf "\t%d\t%.3f", $ovlp_len, $identity;
    printf "\t%d\t%d\t%d\t%d", 0, $f_B, $f_E, $len_of->{$f_id};
    printf "\t%d\t%d\t%d\t%d", $g_ori, $g_B, $g_E, $len_of->{$g_id};

    # relations
    if (    ( $len_of->{$g_id} < $len_of->{$f_id} )
        and ( $g_B < 1 )
        and ( $len_of->{$g_id} - $g_E < 1 ) )
    {
        printf "\tcontains\n";
    }
    elsif ( ( $len_of->{$f_id} < $len_of->{$g_id} )
        and ( $f_B < 1 )
        and ( $len_of->{$f_id} - $f_E < 1 ) )
    {
        printf "\tcontained\n";
    }
    else {
        printf "\toverlap\n";
    }
}
close $in_fh;

exit;

sub get_len_from_header {
    my $fa_fn = shift;

    my %len_of;

    my $fa_fh;
    if ( lc $fa_fn eq 'stdin' ) {
        $fa_fh = *STDIN{IO};
    }
    else {
        open $fa_fh, "<", $fa_fn;
    }

    while ( my $line = <$fa_fh> ) {
        if ( substr( $line, 0, 1 ) eq ">" ) {
            if ( $line =~ /\/(\d+)\/\d+_(\d+)/ ) {
                $len_of{$1} = $2;
            }
        }
    }

    close $fa_fh;

    return \%len_of;
}

sub get_replaces {
    my $fn = shift;

    my $full_replace_of = App::Fasops::Common::read_replaces($fn);

    my $short_replace_of = {};
    for my $key ( sort %{$full_replace_of} ) {
        if ( $key =~ /\/(\d+)\/\d+_\d+/ ) {
            $short_replace_of->{$1} = $full_replace_of->{$key};
        }
    }

    return $short_replace_of;
}
