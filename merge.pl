use strict;
use diagnostics;

my %triplets = ();

open F, '<triplets.tsv'
    or die $!;

<F>;
while (<F>) {
    chomp;
    my ($pii, $hlno) = /(\w+)\t(\d+)/;
    $triplets {"$pii $hlno"} = $_;
}

close F;

open F, '<tree-height.tsv'
    or die $!;

<F>;
while (<F>) {
    chomp;
    my ($pii, $hlno, $hl, $depth, $length) = split /\t/;
    my $t = $triplets {"$pii $hlno"};
    if (defined $t) {
	my @x = split /\t/, $t;
	my $ls = (split / /, $x [2]) + 0;
	my $lv = (split / /, $x [3]) + 0;
	my $lo = (split / /, $x [4]) + 0;
	print "$t\t$depth\t$length\t$ls\t$lv\t$lo\n";
    }
}

close F;

