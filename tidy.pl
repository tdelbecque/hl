use strict;
use diagnostics;

my ($PII, $HLNO, $OK);
my ($SUB, $PRED, $OBJ);
my $SEP = "\t";
$PRED = '';

print STDOUT "pii${SEP}hlno${SEP}sub${SEP}pred${SEP}obj\n";

while (<>) {
    if (/^\d/) {
	if ($PRED ne '') {
	    chop $SUB; chop $PRED; chop $OBJ;
	    print STDOUT "$PII$SEP$HLNO$SEP$SUB$SEP$PRED$SEP$OBJ\n";
	}
	$SUB = $PRED = $OBJ = '';
	if (/PII_FOUND\t(S(?:\d|X)+)/) {
	    $PII = $1;
	    $OK = 0;
	} else {
	    ($HLNO) = /^(\d+)/;
	    $OK = /TRIPLET_FOUND/;
	}
    } else {
	next unless $OK;
	chomp;
	my ($void, $idx, $token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat, $segment) = split /\t/;
	next unless $OK = defined $segment;
	if ($segment eq 'SUB') {
	    $SUB = "$SUB$token ";
	} elsif ($segment eq 'PRED') {
	    $PRED = "$PRED$token ";
	} else {
	    $OBJ = "$OBJ$token ";
	}
    }
}
if ($PRED ne '') {
    chop $SUB; chop $PRED; chop $OBJ;
    print STDOUT "$PII$SEP$HLNO$SEP$SUB$SEP$PRED$SEP$OBJ\n";
}
