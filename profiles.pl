use strict;
use diagnostics;
no warnings 'qw';

my @GRAMS = qw/`` , : . '' $ # CC CD DT EX FW IN JJ JJR JJS -LRB- LS MD NN NNP NNPS NNS PDT POS PRP PRP$ RB RBR RBS RP -RRB- SYM TO UH VB VBD VBG VBN VBP VBZ WDT WP WP$ WRB/;
my @CATS = qw/AMOD DEP NMOD OBJ P PMOD PRD ROOT SBAR SUB VC VMOD/;

my ($IDX, $TOKEN, $DUMMY1, $GRAM1, $GRAM2, $DUMMY2, $PARENT, $CAT, $SEGMENT, $DEPTH) = (0..9);
my (@entries, $ROOT, $PII);
my (%profilGram, %profilCat, %profilGramObj, %profilGramSub);
my ($lengthObj, $lengthSub, $lengthPred) = (0, 0, 0);
my $hlno = 0;
my $status = '';
$" = "\t";

sub resetProfiles {
    $profilCat {$_} = 0 for @CATS;
    $profilGram {$_} = $profilGramObj {$_} = $profilGramSub {$_} = 0 for @GRAMS;
    $lengthObj = $lengthSub = $lengthPred = 0;
}

sub max {
    my ($a, $b) = @_;
    return $a if $a > $b;
    return $b;
}

sub depth {
#    print STDERR "$PII\n";
    my ($e) = @_;
    return $e -> [$DEPTH] = 0 if $e -> [$IDX] == $ROOT;
    my $d = $e -> [$DEPTH];
    return $d if defined $d;
    $e -> [$DEPTH] = depth ($entries [$e -> [$PARENT] - 1]) + 1;
}

sub digest {
    if ($hlno == 0) {
	$hlno = 1;
	return;
    }
    my $hl = '';
    my $segmentObj = '';
    my $segmentPred = '';
    my $segmentSub = '';
    my $segmentOther = '';
    if ($status eq 'TRIPLET_FOUND') {
	my ($maxdepth, $depthSub, $depthObj, $depthPred, $n) = (0, 0, 0, 0, 0);
	my ($depthSubMin, $depthObjMin, $depthPredMin) = (1000, 1000, 1000);
	my ($depthSubMax, $depthObjMax, $depthPredMax) = (-1, -1, -1);
	$#entries -- if $entries [$#entries] -> [$TOKEN] eq '.';
	for my $e (@entries) {
	    $hl .= $e->[$TOKEN] . ' ';
	    my $depth = depth ($e);
	    $maxdepth = $depth if $depth > $maxdepth;
	    $n ++;
	    die $. unless defined $e -> [$SEGMENT];
	    if ($e -> [$SEGMENT] eq 'OBJ') {
		$profilGramObj {$e -> [$GRAM1]} ++;
		$lengthObj ++;
		$depthObjMin = $e -> [$DEPTH] if $e -> [$DEPTH] < $depthObjMin;
		$depthObjMax = $e -> [$DEPTH] if $e -> [$DEPTH] > $depthObjMax;
		$segmentObj .= $e->[$TOKEN] . ' ';
	    } elsif ($e -> [$SEGMENT] eq 'SUB') {
		$profilGramSub {$e -> [$GRAM1]} ++;
		$lengthSub ++;
		$depthSubMin = $e -> [$DEPTH] if $e -> [$DEPTH] < $depthSubMin;
		$depthSubMax = $e -> [$DEPTH] if $e -> [$DEPTH] > $depthSubMax;
		$segmentSub .= $e->[$TOKEN] . ' ';
	    } elsif ($e -> [$SEGMENT] eq 'PRED') {
		$lengthPred ++;
		$depthPredMin = $e -> [$DEPTH] if $e -> [$DEPTH] < $depthPredMin;
		$depthPredMax = $e -> [$DEPTH] if $e -> [$DEPTH] > $depthPredMax;
		$segmentPred .= $e->[$TOKEN] . ' ';
	    } else {
		$segmentOther .= $e->[$TOKEN] . ' ';
	    }
	    $depthSub = $depthSubMax == -1 ? -1 : $depthSubMax - $depthSubMin;
	    $depthObj = $depthObjMax == -1 ? -1 : $depthObjMax - $depthObjMin;
	    $depthPred = $depthPredMax == -1 ? -1 : $depthPredMax - $depthPredMin;
	    $profilGram {$e -> [$GRAM1]} ++;
	    $profilCat {$e -> [$CAT]} ++;
	}
	chop $hl;
	chop $segmentObj;
	chop $segmentPred;
	chop $segmentSub;
	chop $segmentOther;
	print STDOUT "$PII\t$hlno\t$hl\t$segmentSub\t$segmentPred\t$segmentObj\t$segmentOther\t$maxdepth\t$depthSub\t$depthObj\t$depthPred\t$n\t$lengthSub\t$lengthObj\t$lengthPred\t@profilCat{@CATS}\t@profilGram{@GRAMS}\t@profilGramSub{@GRAMS}\t@profilGramObj{@GRAMS}\n";
    }
    $ROOT = undef;
    @entries = ();
    resetProfiles;
    ($lengthObj, $lengthSub) = (0, 0);

    $hlno ++;
}

my $header = "PII\tHLNO\tHL\tSEGSUB\tSEGPRED\tSEGOBJ\tSEGOTHER\tDEPTH\tDEPTHSUB\tDEPTHOBJ\tDEPTHPRED\tNBT\tNBTSUB\tNBTOBJ\tNBTPRED\t";
my @H;
push @H, "DEP_$_" for @CATS;
$header = $header . "@H\t";
@H = ();
push @H, "POS_$_" for @GRAMS;
$header = $header . "@H\t";
@H = ();
push @H, "POS_${_}_SUB" for @GRAMS;
$header = $header . "@H\t";
@H = ();
push @H, "POS_${_}_OBJ" for @GRAMS;
$header = $header . "@H\n";

$header =~ s/''/QLEAVE/g;
$header =~ s/``/QENTER/g;
$header =~ s/,/COMMA/g;
$header =~ s/:/SEMIC/g;
$header =~ s/\./DOR/g;
$header =~ s/-//g;
$header =~ s/\$/DOLLAR/g;
$header =~ s/\#/SHARP/g;

print STDOUT $header;

resetProfiles;

while (<>) {
    chomp;
    if (/^\t/) {
	my ($dummy, $idx, $token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat, $segment) =
	    split /\t/;
	if ($token =~ /^S(\d|X){16}\b/ and $gram1 eq 'CD' and $idx == 1 and $cat eq 'ROOT') {
	    $PII = $token;
	    $hlno = 0;
	} else {
	    push @entries, [$idx, 
			    $token, $dummy1, $gram1, $gram2, $dummy2, $parent, $cat, $segment];
	    $ROOT = $idx if $cat eq 'ROOT';
	    
	}
    } else {
	my $l = $_;
	digest;
	($status) = $l =~ /^\d+\t([^\t]+)/;
    }
}
digest;
    
