# Plants 2+3

## super-reads

###  Ler-0-1, SRR3166543

`-s 300 -d 30` are guessed.

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR3166543
cd ~/data/dna-seq/atha_ler_0/superreads/SRR3166543

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-1/SRR3166543/SRR3166543_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-1/SRR3166543/SRR3166543_2.fastq.gz \
    -s 300 -d 30 -p 16
```

### Ler-0-2, SRR611087

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR611087
cd ~/data/dna-seq/atha_ler_0/superreads/SRR611087

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/SRR611087_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/SRR611087_2.fastq.gz \
    -s 450 -d 50 -p 16
```

### Ler-0-2, SRR616965

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR616965
cd ~/data/dna-seq/atha_ler_0/superreads/SRR616965

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_2.fastq.gz \
    -s 450 -d 50 -p 16
```

### F63, Closterium sp., 新月藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F63
cd ~/data/dna-seq/chara/superreads/F63

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

### F295, Cosmarium botrytis, 葡萄鼓藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F295
cd ~/data/dna-seq/chara/superreads/F295

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

### F340, Zygnema extenue, 亚小双星藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F340
cd ~/data/dna-seq/chara/superreads/F340

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

### F354, Spirogyra gracilis, 纤细水绵

转录本杂合度 0.35%

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F354
cd ~/data/dna-seq/chara/superreads/F354

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

### F357, Botryococcus braunii, 布朗葡萄藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F357
cd ~/data/dna-seq/chara/superreads/F357

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

### F1084, Staurastrum sp., 角星鼓藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F1084
cd ~/data/dna-seq/chara/superreads/F1084

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

### moli, 茉莉

```bash
mkdir -p /home/wangq/zlc/medfood/superreads/moli
cd /home/wangq/zlc/medfood/superreads/moli

perl ~/Scripts/sra/superreads.pl \
    ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000
```

### Summary of SR

| Name       | fq size | fa size | Length | kmer | Est. Genome |   #reads | Run time  |    Sum SR | SR/Est.G |
|:-----------|--------:|--------:|-------:|-----:|------------:|---------:|:---------:|----------:|---------:|
| SRR3166543 |   65.5G |     35G |    100 |   71 |   159276042 | 46692222 | 6:22'54'' | 501353151 |     3.15 |
| SRR611087  |   20.4G |   10.8G |    100 |   71 |   125423153 | 46914691 |   3:13'   | 308181766 |     2.46 |
| SRR616965  |   10.2G |    5.4G |    100 |   71 |   118742701 | 25750807 |   2:40'   | 186951724 |     1.57 |
| F63        |   33.9G |   18.1G |    150 |   49 |   345627684 | 13840871 |   4:30'   | 697371843 |     2.02 |
| F295       |   43.3G |   23.2G |    150 |   49 |   452975652 | 18630254 |   6:1'    | 742260051 |     1.64 |
| F340       |   35.9G |   19.3G |    150 |   75 |   566603922 | 22024705 |   3:21'   | 852873811 |     1.51 |
| F354       |   36.2G |   19.5G |    150 |   49 |   133802786 | 11574363 |   6:6'    | 351863887 |     2.63 |
| F357       |   43.5G |   23.3G |    150 |   49 |   338905264 | 22703546 |   5:41'   | 796466152 |     2.35 |
| F1084      |   33.9G |   18.2G |    150 |   75 |   199395661 |  9895988 |   4:32'   | 570760287 |     2.86 |
| moli       |    258G |    137G |    150 |  105 |   851215891 |          |           |           |          |

Columns:

* fq size - pe.renamed.fastq
* fa size - pe.cor.fa
* L. Reads, kmer, Est. Genome, and #reads from `environment.sh`
* Run time

    ```bash
    secs=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh))
    printf "%d:%d'%d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
    ```

* SR stats

```bash
printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | | \n" \
    $( basename $( pwd ) ) \
    $( if [[ -e pe.renamed.fastq ]]; then du -h pe.renamed.fastq | cut -f1; else echo 0; fi ) \
    $( du -h pe.cor.fa | cut -f1 ) \
    $( cat environment.sh \
        | perl -n -e '/PE_AVG_READ_LENGTH=\"(\d+)\"/ and print $1' ) \
    $( cat environment.sh \
        | perl -n -e '/KMER=\"(\d+)\"/ and print $1' ) \
    $( cat environment.sh \
        | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' ) \
    $( cat environment.sh \
        | perl -n -e '/TOTAL_READS=\"(\d+)\"/ and print $1' ) \
    $( secs=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh)); \
        printf "%d:%d'%d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) ) \
    $( faops n50 -H -N 0 -S work1/superReadSequences.fasta)

```


Thoughts:

* kmer 与污染的关系还不好说
* kmer 估计基因组比真实的大得越多, 污染就越多
* 有多个因素会影响 SR/Est.G. 细菌与单倍体会趋向于 2, paralog 与杂合会趋向于 4.
* 50 倍的二代数据并不充分, 与 100 倍之间还是有明显的差异的. 覆盖数不够也会导致 SR/Est.G 低于真实值.

## Anchors

```bash
TOLERATE_SUBS=true
MIN_LENGTH_READ=100

mkdir -p sr
cd sr

ln -s ../pe.cor.fa .
ln -s ../work1/superReadSequences.fasta .

faops size superReadSequences.fasta > sr.chr.sizes

if [ "${TOLERATE_SUBS}" = true ]; then
    # tolerates 1 substitution
    cat pe.cor.fa \
        | perl -nle '/>/ or next; /sub.+sub/ and next; />(\w+)/ and print $1;' \
        > pe.strict.txt
else
    # discard any reads with substitutions
    cat pe.cor.fa \
        | perl -nle '/>/ or next; /sub/ and next; />(\w+)/ and print $1;' \
        > pe.strict.txt
fi

# Too large for `faops some`
split -n10 -d pe.strict.txt pe.part

# No Ns; longer than 100 bp (70% of read length)
rm pe.strict.fa
for part in $(printf "%.2d " {0..9})
do 
    faops some -l 0 pe.cor.fa pe.part${part} stdout \
        | faops filter -n 0 -a ${MIN_LENGTH_READ} -l 0 stdin stdout
    rm pe.part${part}
done >> pe.strict.fa

#----------------------------#
# unambiguous
#----------------------------#
# index
bbmap.sh ref=superReadSequences.fasta

bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    ambiguous=toss \
    ref=superReadSequences.fasta in=pe.strict.fa \
    outm=unambiguous.sam outu=unmapped.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=unambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam unambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam unambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        $F[3] == 1 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > unambiguous.cover.txt

#----------------------------#
# ambiguous
#----------------------------#
cat unmapped.sam \
    | perl -nle '
        /^@/ and next;
        @fields = split "\t";
        print $fields[0];
    ' \
    > pe.unmapped.txt

# Too large for `faops some`
split -n10 -d pe.unmapped.txt pe.part

rm pe.unmapped.fa
for part in $(printf "%.2d " {0..9})
do 
    faops some -l 0 pe.strict.fa pe.part${part} stdout
    rm pe.part${part}
done >> pe.unmapped.fa

bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    ref=superReadSequences.fasta in=pe.unmapped.fa \
    outm=ambiguous.sam outu=unmapped2.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=ambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam ambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam ambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > ambiguous.cover.txt

#----------------------------#
# anchor
#----------------------------#
jrunlist cover unambiguous.cover.txt 
runlist stat unambiguous.cover.txt.yml -s sr.chr.sizes -o unambiguous.cover.csv

jrunlist cover ambiguous.cover.txt 
runlist stat ambiguous.cover.txt.yml -s sr.chr.sizes -o ambiguous.cover.csv

runlist compare --op diff unambiguous.cover.txt.yml ambiguous.cover.txt.yml -o unique.cover.yml
runlist stat unique.cover.yml -s sr.chr.sizes -o unique.cover.csv

cat unique.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

faops some -l 0 superReadSequences.fasta anchor.txt pe.anchor.fa

#----------------------------#
# anchor2
#----------------------------#
jrunlist span unique.cover.yml --op excise -n 1000 -o stdout \
    | runlist stat stdin -s sr.chr.sizes -o unique2.cover.csv

cat unique2.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
        print $F[0];
    ' \
    | sort -n \
    > unique2.txt

cat unique2.txt \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{anchor.txt})->lines({ chomp => 1});
            $seen{$_}++ for @ls;
        }
        
        $seen{$_} and next;
        print;
    ' \
    > anchor2.txt

faops some -l 0 superReadSequences.fasta anchor2.txt pe.anchor2.fa

faops some -l 0 -i superReadSequences.fasta anchor.txt stdout \
    | faops some -l 0 -i stdin anchor2.txt pe.others.fa

rm unique2.cover.csv unique2.txt

#----------------------------#
# record unique regions
#----------------------------#

cat pe.anchor2.fa \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{unique.cover.yml})->lines({ chomp => 1});
            for (@ls) {
                /^(\d+):\s+([\d,-]+)/ or next;
                $seen{$1} = $2;
            }
            $flag = 0;
        }
        
        if (/^>(\d+)/) {
            if ($seen{$1}) {
                print qq{>$1|$seen{$1}};
                $flag = 1;
            }
        }
        elsif (/^\w+/) {
            if ($flag) {
                print;
                $flag = 0;
            }
        }
    ' \
    > pe.anchor2.record.fa

cat pe.others.fa \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{unique.cover.yml})->lines({ chomp => 1});
            for (@ls) {
                /^(\d+):\s+([\d,-]+)/ or next;
                $seen{$1} = $2;
            }
            $flag = 0;
        }
        
        if (/^>(\d+)/) {
            if ($seen{$1}) {
                print qq{>$1|$seen{$1}};
            }
            else {
                print;
            }
            $flag = 1;
        }
        elsif (/^\w+/) {
            if ($flag) {
                print;
                $flag = 0;
            }
        }
    ' \
    > pe.others.record.fa

#----------------------------#
# reports
#----------------------------#
faops n50 -N 50 -S -C superReadSequences.fasta
faops n50 -N 0 -C pe.cor.fa
faops n50 -N 0 -C pe.strict.fa

printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
    $( basename $( dirname $(pwd) ) ) \
    $( faops n50 -H -N 50 -S -C pe.anchor.fa) \
    $( faops n50 -H -N 50 -S -C pe.anchor2.fa) \
    $( faops n50 -H -N 50 -S -C pe.others.fa)

```

| Name       | N50 SR |    Sum SR |     #SR |   #cor.fa | #strict.fa |
|:-----------|-------:|----------:|--------:|----------:|-----------:|
| SRR3166543 |   1929 | 501353151 | 1313227 | 324725120 |  299807953 |
| SRR611087  |   5338 | 308181766 |  722096 | 101582900 |   97625637 |
| SRR616965  |   1643 | 186951724 |  488218 |  50872510 |   48928772 |
| F63        |   1815 | 697371843 |  986675 | 115078314 |   94324950 |
| F295       |    477 | 742260051 | 1975444 | 146979656 |  119415569 |
| F340       |    388 | 852873811 | 2383927 | 122062736 |  102014388 |
| F354       |    768 | 351863887 |  584408 | 123057622 |  106900181 |
| F357       |    599 | 796466152 | 1644428 | 147581634 |  129353409 |
| F1084      |    893 | 570760287 |  882123 | 115210566 |   97481899 |

| Name       |  N50 |      Sum | #anchor |   N50 |      Sum | #anchor2 |  N50 |       Sum | #others |
|:-----------|-----:|---------:|--------:|------:|---------:|---------:|-----:|----------:|--------:|
| SRR3166543 | 5223 |  3609543 |    1119 |  8810 |  2717807 |      448 | 1897 | 495025801 | 1311660 |
| SRR611087  | 8829 | 10146708 |    1656 | 10999 | 32989092 |     4024 | 4093 | 265045966 |  716416 |
| SRR616965  | 3707 | 80021452 |   26553 |  3955 | 11905443 |     3481 |  209 |  95024829 |  458184 |
| F63        | 4003 | 52342433 |   21120 |       |          |          |      |           |         |
| F295       | 2118 | 17374987 |   10473 |       |          |          |      |           |         |
| F340       | 1105 | 76859329 |   70742 |       |          |          |      |           |         |
| F354       | 2553 | 23543840 |   11667 |       |          |          |      |           |         |
| F357       | 1541 | 53821193 |   40017 |       |          |          |      |           |         |
| F1084      | 1721 |  4412080 |    3059 |       |          |          |      |           |         |

Clear intermediate files.

```bash
# masurca
find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "pe.linking.fa" | xargs rm
find . -type f -name "pe.linking.frg" | xargs rm
find . -type f -name "superReadSequences_shr.frg" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
find . -type f -name "pe.renamed.fastq" | xargs rm

# anchor
find . -type f -name "ambiguous.sam" | xargs rm
find . -type f -name "unambiguous.sam" | xargs rm
find . -type f -name "unmapped.sam" | xargs rm
find . -type f -name "pe.unmapped.fa" | xargs rm
```
