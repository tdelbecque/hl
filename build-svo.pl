use strict;
use diagnostics;

my ($IDX, $TOKEN, $DUMMY1, $GRAM1, $GRAM2, $DUMMY2, $PARENT, $CAT, $SEGMENT) = (0..8);
my (@entries, $ROOT, $SUB, $OBJ, $status);
my $hlno = 0;

$" = "\t";

sub getSegment {
    my ($e) = @_;
    my $segment = $e -> [$SEGMENT];
    return $segment if defined $segment;

    my $idx = $e -> [$IDX];
    die "@$e" unless defined $idx;
    if ($idx == $ROOT) {
	push @$e, ($segment = 'PRED');
    } elsif ($idx == $SUB) {
	push @$e, ($segment = 'SUB');
    } elsif ($idx == $OBJ) {
	push @$e, ($segment = 'OBJ');
    } else {
	$segment = getSegment ($entries [$e -> [$PARENT] - 1]);
	$segment = 'UNK' if $segment eq 'PRED';
	push @$e, $segment;
    }
    return $segment;
}

sub digest {
    if (defined $ROOT) {
	for my $e (@entries) {
	    $SUB = $e -> [$IDX] if $e -> [$CAT] eq 'SUB' and $e -> [$PARENT] == $ROOT;
	    $OBJ = $e -> [$IDX] if $e -> [$CAT] eq 'OBJ' and $e -> [$PARENT] == $ROOT;
	}
	if ($SUB && $OBJ) {
	    for my $e (@entries) {
		getSegment ($e);
	    }
	    $status = "TRIPLET_FOUND";
	} else {
	    $status = "NOT_A_TRIPLET" unless defined $status;
	}
    } else {
	$status = "NOT_ROOTED";
    }

    print STDOUT "$hlno\t$status\n";
    for my $e (@entries) {
	print STDOUT "\t@$e\n";
    }
    
    $ROOT = $SUB = $OBJ = $status = undef;
    $hlno ++;
    @entries = ();
}

while (<>) {
    chomp;
    if (/^\d/) {
	my ($idx, $token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat) =
	    split /\t/;
	push @entries, [$idx, 
			$token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat];
	if ($cat eq 'ROOT') {
	    if ($token =~ /S(\d|X){16}\b/ and $gram1 eq 'CD') {
		$status = "PII_FOUND\t$token";
		$hlno = 0;
	    }
	    $ROOT = $idx;
	}
    } else {
	digest;
    }
}
digest;
