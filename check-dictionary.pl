use strict;
use diagnostics;

my %dico;

open DIC, '</usr/share/dict/american-english'
    or die $!;

while (<DIC>) {
    chomp;
    $_ = lc;
    $dico{$_} = 1;
}

close DIC;

print STDERR "!\n";

open COMPOUND, ">vocab-compound.tsv"
    or die $!;
open KNOWN, ">vocab-known.tsv"
    or die $!;
open UNKNOWN, ">vocab-unknown.tsv"
    or die $!;
open NALPHA, ">vocab-nonalpha.tsv"
    or die $!;

while (<>) {
    my ($n,$t) = /\s*(\d+) (.+)/;
    next if $t =~ /^[0-9+-,;:!?.&()\[\]\{\}"'\@\$\%*\/\\=<>]+$/;
    if ($t =~ /^[a-zA-Z]+[^0-9a-zA-Z][a-zA-Z]+$/) {
	print COMPOUND;
	next;
    }
    my $l = lc $t;
    if ($l =~ /[^a-z]/) {
	print NALPHA;
    } elsif ($dico {$l}) {
	print KNOWN;
    } else {
	print UNKNOWN;
    }
}

close COMPOUND;
close KNOWN;
close UNKNOWN;
close NALPHA;
