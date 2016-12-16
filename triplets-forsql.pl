use strict;
use diagnostics;

my ($PII, $HLNO);

print STDOUT "pii\thlno\ttokno\ttoken\tgram\tparent\tcat\tsegment\n";

while (<>) {
    if (/\d/) {
	chomp;
	if (/^\t1\t(S(?:\d|X){16})\t/) {
	    $PII = $1;
	} elsif (/^\t/) {
	    my @x = split /\t/;
	    push @x, "UNK";
	    my $x = "$x[1]\t$x[2]\t$x[4]\t$x[7]\t$x[8]\t$x[9]";
	    print STDOUT "$PII\t$HLNO\t$x\n";
	} else {
	    ($HLNO) = /^(\d+)/;
	}
    }
}
