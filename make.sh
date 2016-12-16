tail -n +2 SD_PII_Highlights.tsv | perl -ne 's/\t+/ /g; s/\s*\xe2\x80\xa2\s*/\n/g; print' | perl -ne 'print if /[a-zA-Z]/' > highlights.1

../scripts/parse.sh highlights.1

cut -f 2 ../scripts/tmp/tmp.conll.predpos.pred | perl -ne 'print if /./ and not /S.{16}$/' | sort | uniq -c | sort -nr -k 1 > foo

perl check-dictionary.pl < foo

perl build-predicates.pl < ../scripts/tmp/tmp.conll.predpos.pred > triplets-2
perl tidy.pl < triplets-2 > triplets-2.tsv
