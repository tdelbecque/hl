use strict;
use diagnostics;

my ($IDX, $TOKEN, $DUMMY1, $GRAM1, $GRAM2, $DUMMY2, $PARENT, $CAT, $DEPTH) = (0..8);
my (@entries, $ROOT, $PII);
my $hlno = 0;

$" = "\t";

sub max {
    my ($a, $b) = @_;
    return $a if $a > $b;
    return $b;
}

sub depth {
#    print STDERR "$PII\n";
    my ($e) = @_;
    return 0 if $e -> [$IDX] == $ROOT;
    my $d = $e -> [$DEPTH];
    return $d if defined $d;
    $e -> [$DEPTH] = depth ($entries [$e -> [$PARENT] - 1]) + 1;
}

sub digest {
    if ($hlno == 0) {
	$hlno = 1;
	return;
    }
    my $hl = ' ';
    if (defined $ROOT) {
	my ($maxdepth, $n) = (0, 0);
	for my $e (@entries) {
	    $hl = "$hl$e->[$TOKEN] ";
	    my $depth = depth ($e);
	    $maxdepth = $depth if $depth > $maxdepth;
	    $n ++;
	}
	chop $hl;
	print STDOUT "$PII\t$hlno\t$hl\t$maxdepth\t$n\n";
    } else {
	for my $e (@entries) {
	    $hl = "$hl$e->[$TOKEN] ";
	}
	chop $hl;
	print STDOUT "$PII\t$hlno\t$hl\t-1\t-1\n";
    }
    $ROOT = undef;
    @entries = ();
    $hlno ++;
}

print STDOUT "pii\thlno\tHL\tdepth\tnbtokens\n";
while (<>) {
    chomp;
    if (/^\d/) {
	my ($idx, $token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat) =
	    split /\t/;
	if ($token =~ /^S(\d|X){16}\b/ and $gram1 eq 'CD' and $idx == 1 and $cat eq 'ROOT') {
	    $PII = $token;
	    $hlno = 0;
	} else {
	    push @entries, [$idx, 
			    $token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat];
	    $ROOT = $idx if $cat eq 'ROOT';
	}
    } else {
	digest
    }
}
digest;
    
