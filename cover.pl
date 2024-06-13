
#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw( min max );

my $Tab = shift;

my %SeqH;

open IN, "<$Tab" or die $!;

while(<IN>){

	chomp;

	my @tt = split /\t/;

	if(! exists $SeqH{$tt[12]}){

		$SeqH{$tt[12]} = [ min($tt[8], $tt[9]), max($tt[8], $tt[9]) ];

	}else{

		$SeqH{$tt[12]} = [ min($tt[8], $tt[9], $SeqH{$tt[12]}[0]), max($tt[8], $tt[9], $SeqH{$tt[12]}[1]) ];

	}

}

close IN;

foreach my $kk (keys %SeqH){

	print "$kk\t$SeqH{$kk}[0]\t$SeqH{$kk}[1]\t".length($kk)."\t".substr($kk, $SeqH{$kk}[0] - 1, $SeqH{$kk}[1] - $SeqH{$kk}[0] + 1)."\t".substr($kk, $SeqH{$kk}[0] - 1, length($kk)/2 - $SeqH{$kk}[0] + 1)."\t".substr($kk, length($kk)/2, $SeqH{$kk}[1] - length($kk)/2)."\n";

}

