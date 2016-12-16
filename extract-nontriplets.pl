use strict;
use diagnostics;

my ($PII, $HLNO, $HL) = ('', 0, '');

print STDOUT "pii\thlno\thl\n";

while (<>) {
    if (/^\d/ and $HL ne '') {
	chop $HL;
	print STDOUT "$PII\t$HLNO\t$HL\n";
	$HL = '';
	$HLNO = 0;
    }
    if (/PII_FOUND\t(S.+)$/) {
	$PII = $1;
	next;
    }
    if (/(\d+)\t(?:NOT_A_TRIPLET|NOT_ROOTED)/) {
	$HLNO = $1;
	next;
    } 
    next unless $HLNO;
    my ($token) = /^\t\d+\t(.+?)\t/;
    $HL = "$HL$token ";
}

if ($HL ne '') {
    chop $HL;
    print STDOUT "$PII\t$HLNO\t$HL\n";
}

