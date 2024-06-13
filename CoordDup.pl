
#!/usr/bin/perl

use strict;
use warnings;

my $Tab = shift;

open IN, "<$Tab" or die $!;

my %Hash;
my %Hash_2;

while(<IN>){

	my @tt = split /\t/;

	my $ID = "";

	my $Len = 0;

	if($tt[0]=~/(NC\S+)_(N[MR]\S+)/){

		my @ttt = split(/_/, $1);

		$ID = "$ttt[0]_$ttt[1]_$tt[2]_$tt[4]_$tt[5]";

		$Len = $ttt[3] - $ttt[2];

	}elsif($tt[0]=~/(N[MR]\S+)_(NC\S+)/){

		my @ttt = split(/_/, $2);

		$ID = "$ttt[0]_$ttt[1]_$tt[2]_$tt[4]_$tt[5]";

		$Len = $ttt[3] - $ttt[2];

	}else{

		next;

	}

	if(!exists($Hash{$ID})){

		$Hash{$ID} = $Len;

		$Hash_2{$ID} = join("\t", @tt);

	}else{

		if($Len > $Hash{$ID}){

			$Hash{$ID} = $Len;

			$Hash_2{$ID} = join("\t", @tt);

		}else{	

			next;

		}

	}

}

foreach my $key (keys %Hash_2){

	print $Hash_2{$key};

}

