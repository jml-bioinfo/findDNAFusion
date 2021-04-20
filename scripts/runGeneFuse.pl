#!/usr/local/bin/perl


use strict;
use Getopt::Long;
use Cwd qw(cwd);
use POSIX qw(strftime);


=head1 NAME

runGeneFuse.pl


=head2 SYNOPSIS

perl runGeneFuse.pl -i input-dir -o output-dir


=head3 DESCRIPTION

This PERL script to run multiple jobs using GeneFuse.


=head4 AUTHOR

Xiaokang Pan (Xiaokang.Pan@osumc.edu)


=head5 LAST UPDATE

04/19/2021

=cut


my $usage = <<EOS;
   Usage: perl $0 [-options]

   -i|inpath	[string] (input dir storing fastq files at directory)
   -o|outpath	[string] (output dir storng outputs from GeneFuse)
   -t|time    [string] (expected waiting time in minutes to start actual run)
   -h|help (help information)

EOS

my ($inpath, $outpath, $time, $help);
GetOptions (
  "inpath=s"  => \$inpath,        # input dir 
  "outpath:s" => \$outpath,       # output dir
  "time:s"    => \$time,          # expected waiting time in minutes
  "help:s"    => \$help		  # help information
);
die "\n$usage\n" if ($help or
                     !defined($inpath));

my $current_path = cwd;
if (!$outpath) {

    system("mkdir genefuse-output");
    $outpath = $current_path."/genefuse-output";

} elsif ($outpath !~ /^.+\/.+$/) {
    $outpath = $current_path."/".$outpath;
}

if ($time) {
   $time  = $time."m";
   system("sleep $time");
}

my @files = <$inpath/*.fastq.gz>;

my %samples;
foreach my $file (@files) {

    my $sample_name;
        
    if ($file =~ /^.+\/(.+)_R\d\.fastq\.gz$/) {
        $sample_name = $1;
        $samples{$sample_name} = 1;
    }
}

my $ref_file = "input_data/hg19.fasta";
my $fusionGenes = "input_data/PossibleFusionGenes.csv";

foreach my $sample (sort keys %samples) {
   my $r1_fastq_file = "$inpath/$sample"."_R1.fastq.gz";
   my $r2_fastq_file = "$inpath/$sample"."_R2.fastq.gz";
   system("nohup genefuse -r $ref_file -f $fusionGenes -1 $r1_fastq_file -2 $r2_fastq_file -t 8 -u 5 -h $outpath/$sample.html > $outpath/$sample-fusion.txt &");

}


