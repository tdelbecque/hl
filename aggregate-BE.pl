use strict;
use diagnostics;

my %D = ();
my @D = ();

while (<>) {
    chomp;
    s/\s\.$//;
    s/\t(?:is|are|was|were)\t/\tBE\t/i;
    s/\tha(?:ve|s)\tbeen\s/\tBE\t/i;
    my ($n, $s) = /^(\d+)\t(.+)/;
    my $p = $D {$s} || 0;
    $D {$s} = $p + $n;
}

while (my ($k, $v) = each %D) {
    push @D, [$v, $k];
}

for (sort {$b->[0] <=> $a->[0]} @D) {
    print STDOUT "$_->[0]\t$_->[1]\n";
}
