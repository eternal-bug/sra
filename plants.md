# Plants 2+3

[TOC levels=1-3]: # " "

- [Plants 2+3](#plants-23)
- [F63, Closterium sp., 新月藻](#f63-closterium-sp-新月藻)
    - [F63: download](#f63-download)
    - [F63: combinations of different quality values and read lengths](#f63-combinations-of-different-quality-values-and-read-lengths)
    - [F63: down sampling](#f63-down-sampling)
    - [F63: generate super-reads](#f63-generate-super-reads)
    - [F63: create anchors](#f63-create-anchors)
    - [F63: results](#f63-results)
    - [F63: merge anchors](#f63-merge-anchors)
- [F295, Cosmarium botrytis, 葡萄鼓藻](#f295-cosmariumbotrytis-葡萄鼓藻)
    - [F295: download](#f295-download)
    - [F295: combinations of different quality values and read lengths](#f295-combinations-of-different-quality-values-and-read-lengths)
    - [F295: down sampling](#f295-down-sampling)
    - [F295: generate super-reads](#f295-generate-super-reads)
    - [F295: create anchors](#f295-create-anchors)
    - [F295: results](#f295-results)
    - [F295: merge anchors](#f295-merge-anchors)
- [F340, Zygnema extenue, 亚小双星藻](#f340-zygnema-extenue-亚小双星藻)
    - [F340: download](#f340-download)
    - [F340: combinations of different quality values and read lengths](#f340-combinations-of-different-quality-values-and-read-lengths)
    - [F340: down sampling](#f340-down-sampling)
    - [F340: generate super-reads](#f340-generate-super-reads)
    - [F340: create anchors](#f340-create-anchors)
    - [F340: results](#f340-results)
    - [F340: merge anchors](#f340-merge-anchors)
- [F354, Spirogyra gracilis, 纤细水绵](#f354-spirogyragracilis-纤细水绵)
    - [F354: download](#f354-download)
    - [F354: combinations of different quality values and read lengths](#f354-combinations-of-different-quality-values-and-read-lengths)
    - [F354: down sampling](#f354-down-sampling)
    - [F354: generate super-reads](#f354-generate-super-reads)
    - [F354: create anchors](#f354-create-anchors)
    - [F354: results](#f354-results)
    - [F354: merge anchors](#f354-merge-anchors)
- [F357, Botryococcus braunii, 布朗葡萄藻](#f357-botryococcus-braunii-布朗葡萄藻)
    - [F357: download](#f357-download)
    - [F357: combinations of different quality values and read lengths](#f357-combinations-of-different-quality-values-and-read-lengths)
    - [F357: down sampling](#f357-down-sampling)
    - [F357: generate super-reads](#f357-generate-super-reads)
    - [F357: create anchors](#f357-create-anchors)
    - [F357: results](#f357-results)
    - [F357: merge anchors](#f357-merge-anchors)
- [F1084, Staurastrum sp., 角星鼓藻](#f1084-staurastrumsp-角星鼓藻)
    - [F1084: download](#f1084-download)
    - [F1084: combinations of different quality values and read lengths](#f1084-combinations-of-different-quality-values-and-read-lengths)
    - [F1084: down sampling](#f1084-down-sampling)
    - [F1084: generate super-reads](#f1084-generate-super-reads)
    - [F1084: create anchors](#f1084-create-anchors)
    - [F1084: results](#f1084-results)
    - [F1084: merge anchors](#f1084-merge-anchors)
- [moli, 茉莉](#moli-茉莉)
- [Summary of SR](#summary-of-sr)
- [Anchors](#anchors)


# F63, Closterium sp., 新月藻

## F63: download

```bash
mkdir -p ~/data/dna-seq/chara/F63/2_illumina
cd ~/data/dna-seq/chara/F63/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_2.clean.fq.gz R2.fq.gz
```

## F63: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 17261747100 | 115078314 |
| scythe   | 150 | 17238905226 | 115078314 |
| Q20L100  | 150 | 14613528978 |  99629220 |
| Q20L110  | 150 | 14090763901 |  95490964 |
| Q20L120  | 150 | 13326124619 |  89685350 |
| Q20L130  | 150 | 12513977672 |  83752968 |
| Q20L140  | 150 | 11854985260 |  79097958 |
| Q20L150  | 150 | 10454746500 |  69698310 |
| Q25L100  | 150 | 12650746414 |  87412070 |
| Q25L110  | 150 | 11932592897 |  81717906 |
| Q25L120  | 150 | 10846899499 |  73469252 |
| Q25L130  | 150 |  9705508449 |  65129662 |
| Q25L140  | 150 |  8730498656 |  58248184 |
| Q25L150  | 150 |  7867688100 |  52451254 |
| Q30L100  | 150 | 10219013065 |  72127568 |
| Q30L110  | 150 |  9232141568 |  64295722 |
| Q30L120  | 150 |  7785522133 |  53295434 |
| Q30L130  | 150 |  6385425253 |  43060440 |
| Q30L140  | 150 |  5251817662 |  35059802 |
| Q30L150  | 150 |  4332341100 |  28882274 |

## F63: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F63: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F63: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F63: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |    RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|-----------:|
| Q20L100 | 14.61G | 146.1 |     138 |   43 | 11.38G |  22.095% |  100M | 269.92M |     2.70 | 310.51M |     0 | 11:54'30'' |
| Q20L110 | 14.09G | 140.9 |     140 |   45 | 11.06G |  21.475% |  100M | 266.44M |     2.66 | 303.83M |     0 | 11:08'56'' |
| Q20L120 | 13.33G | 133.3 |     145 |   49 | 10.57G |  20.674% |  100M | 261.16M |     2.61 |  295.1M |     0 |  7:37'09'' |
| Q20L130 | 12.51G | 125.1 |     148 |   49 | 10.02G |  19.928% |  100M | 255.27M |     2.55 | 285.24M |     0 |  5:25'40'' |
| Q20L140 | 11.85G | 118.5 |     149 |   49 |  9.57G |  19.305% |  100M | 250.24M |     2.50 | 277.47M |     0 |  6:28'27'' |
| Q20L150 | 10.45G | 104.5 |     150 |   49 |  8.49G |  18.786% |  100M | 239.26M |     2.39 | 262.86M |     0 |  5:35'35'' |
| Q25L100 | 12.65G | 126.5 |     136 |   41 | 10.63G |  15.934% |  100M | 256.71M |     2.57 | 283.18M |     0 |  7:00'09'' |
| Q25L110 | 11.93G | 119.3 |     138 |   43 | 10.08G |  15.532% |  100M | 251.42M |     2.51 | 275.71M |     0 |  5:39'30'' |
| Q25L120 | 10.85G | 108.5 |     143 |   49 |  9.21G |  15.095% |  100M | 242.75M |     2.43 | 264.82M |     0 |  5:24'53'' |
| Q25L130 |  9.71G |  97.1 |     148 |   49 |  8.27G |  14.782% |  100M | 232.51M |     2.33 | 252.37M |     0 |  4:13'33'' |
| Q25L140 |  8.73G |  87.3 |     149 |   49 |  7.47G |  14.452% |  100M | 222.71M |     2.23 | 240.92M |     0 |  2:01'58'' |
| Q25L150 |  7.87G |  78.7 |     150 |   49 |  6.73G |  14.400% |  100M | 213.58M |     2.14 | 230.55M |     0 |  1:49'52'' |
| Q30L100 | 10.22G | 102.2 |     133 |   41 |  9.02G |  11.742% |  100M | 237.32M |     2.37 |  257.6M |     0 |  2:28'21'' |
| Q30L110 |  9.23G |  92.3 |     137 |   45 |  8.16G |  11.596% |  100M | 228.04M |     2.28 | 246.47M |     0 |  2:04'33'' |
| Q30L120 |  7.79G |  77.9 |     142 |   49 |  6.88G |  11.578% |  100M | 212.25M |     2.12 | 228.69M |     0 |  1:44'10'' |
| Q30L130 |  6.39G |  63.9 |     147 |   49 |  5.63G |  11.777% |  100M | 193.79M |     1.94 | 208.25M |     0 |  1:19'28'' |
| Q30L140 |  5.25G |  52.5 |     149 |   49 |  4.63G |  11.894% |  100M | 176.36M |     1.76 | 189.09M |     0 |  1:03'17'' |
| Q30L150 |  4.33G |  43.3 |     150 |   49 |  3.79G |  12.475% |  100M | 160.68M |     1.61 | 171.94M |     0 |  0:50'21'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |      # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|------:|-----:|----------:|--------:|-------:|----------:|
| Q20L100 |       1619 | 310.51M | 1014176 |      5693 | 170.56M | 43426 |       1393 | 6.15M | 4317 |       210 |  133.8M | 966433 | 1:28'11'' |
| Q20L110 |       1688 | 303.83M |  912085 |      5890 | 169.43M | 42635 |       1385 | 6.19M | 4351 |       222 | 128.22M | 865099 | 1:20'49'' |
| Q20L120 |       1734 |  295.1M |  795210 |      6659 | 166.51M | 40555 |       1373 | 6.19M | 4389 |       236 |  122.4M | 750266 | 0:47'50'' |
| Q20L130 |       1795 | 285.24M |  713613 |      7113 | 162.98M | 39090 |       1381 | 6.39M | 4510 |       253 | 115.87M | 670013 | 1:14'29'' |
| Q20L140 |       1835 | 277.47M |  656911 |      7572 | 159.61M | 37736 |       1385 | 6.48M | 4560 |       270 | 111.38M | 614615 | 1:20'58'' |
| Q20L150 |       1801 | 262.86M |  583052 |      8460 | 149.64M | 33928 |       1372 | 6.56M | 4674 |       303 | 106.65M | 544450 | 1:29'51'' |
| Q25L100 |       2203 | 283.18M |  699445 |      6326 | 172.04M | 41847 |       1380 | 5.71M | 4036 |       261 | 105.42M | 653562 | 0:46'38'' |
| Q25L110 |       2234 | 275.71M |  629842 |      6983 | 168.15M | 39783 |       1380 | 5.72M | 4041 |       278 | 101.84M | 586018 | 0:42'58'' |
| Q25L120 |       2127 | 264.82M |  548435 |      9023 | 158.69M | 35057 |       1366 | 5.85M | 4192 |       301 | 100.28M | 509186 | 1:19'17'' |
| Q25L130 |       2070 | 252.37M |  502518 |     10320 | 149.25M | 31594 |       1351 |    6M | 4332 |       322 |  97.12M | 466592 | 1:16'36'' |
| Q25L140 |       2039 | 240.92M |  467988 |     11608 |  140.6M | 28261 |       1339 | 5.69M | 4146 |       336 |  94.63M | 435581 | 1:10'54'' |
| Q25L150 |       2074 | 230.55M |  442151 |     12731 | 132.86M | 25054 |       1329 | 5.32M | 3901 |       343 |  92.36M | 413196 | 0:54'30'' |
| Q30L100 |       2341 |  257.6M |  546867 |      8069 | 159.78M | 36527 |       1344 | 5.33M | 3877 |       305 |  92.49M | 506463 | 1:07'30'' |
| Q30L110 |       2315 | 246.47M |  485170 |     10278 | 149.95M | 31561 |       1329 | 5.06M | 3715 |       325 |  91.47M | 449894 | 1:06'39'' |
| Q30L120 |       2315 | 228.69M |  431288 |     13847 |  134.4M | 24452 |       1311 | 4.35M | 3233 |       341 |  89.94M | 403603 | 0:50'44'' |
| Q30L130 |       2633 | 208.25M |  386506 |     13223 | 121.14M | 20330 |       1300 | 3.45M | 2570 |       341 |  83.65M | 363606 | 1:04'22'' |
| Q30L140 |       2742 | 189.09M |  345297 |     11851 | 110.78M | 19133 |       1312 | 2.96M | 2178 |       332 |  75.35M | 323986 | 0:27'01'' |
| Q30L150 |       2600 | 171.94M |  309601 |     10936 | 101.73M | 18708 |       1348 | 2.88M | 2083 |       322 |  67.32M | 288810 | 0:50'20'' |

## F63: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L110/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L130/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q20L150/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L110/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L130/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q25L150/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L110/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L130/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q30L150/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L110/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L130/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q20L150/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L110/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L130/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q25L150/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L110/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L130/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    Q30L150/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# F295, Cosmarium botrytis, 葡萄鼓藻

## F295: download

```bash
mkdir -p ~/data/dna-seq/chara/F295/2_illumina
cd ~/data/dna-seq/chara/F295/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

## F295: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 22046948400 | 146979656 |
| scythe   | 150 | 22015725890 | 146979656 |
| Q20L100  | 150 | 19085875980 | 130371314 |
| Q20L110  | 150 | 18335048576 | 124375122 |
| Q20L120  | 150 | 17327774659 | 116688314 |
| Q20L130  | 150 | 16192978459 | 108384610 |
| Q20L140  | 150 | 15276645865 | 101909704 |
| Q20L150  | 150 | 14078317500 |  93855450 |
| Q25L100  | 150 | 16854549405 | 116554392 |
| Q25L110  | 150 | 15858973942 | 108581370 |
| Q25L120  | 150 | 14485090137 |  98086328 |
| Q25L130  | 150 | 12982514417 |  87086786 |
| Q25L140  | 150 | 11739819388 |  78312454 |
| Q25L150  | 150 | 11003809200 |  73358728 |
| Q30L100  | 150 | 14095170031 |  99140622 |
| Q30L110  | 150 | 12832856338 |  89011084 |
| Q30L120  | 150 | 11121894458 |  75927340 |
| Q30L130  | 150 |  9347502410 |  62930872 |
| Q30L140  | 150 |  7914150289 |  52811380 |
| Q30L150  | 150 |  7034036400 |  46893576 |

## F295: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F295: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F295: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F295: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 19.09G | 190.9 |     130 |   39 | 14.56G |  23.712% |  100M | 240.32M |     2.40 | 432.23M |     0 | 4:24'09'' |
| Q20L110 | 18.34G | 183.4 |     137 |   45 | 14.09G |  23.129% |  100M | 235.02M |     2.35 | 424.17M |     0 | 4:13'48'' |
| Q20L120 | 17.33G | 173.3 |     144 |   47 | 13.43G |  22.482% |  100M | 228.34M |     2.28 | 397.88M |     0 | 4:47'25'' |
| Q20L130 | 16.19G | 161.9 |     148 |   49 | 12.66G |  21.833% |  100M | 221.02M |     2.21 | 370.17M |     0 | 3:23'34'' |
| Q20L140 | 15.28G | 152.8 |     149 |   49 | 12.03G |  21.271% |  100M | 215.12M |     2.15 | 348.53M |     0 | 3:10'02'' |
| Q20L150 | 14.08G | 140.8 |     150 |   49 | 11.13G |  20.967% |  100M | 206.81M |     2.07 | 326.72M |     0 | 2:37'19'' |
| Q25L100 | 16.85G | 168.5 |     128 |   37 |  13.7G |  18.701% |  100M | 224.75M |     2.25 | 367.05M |     0 | 2:28'10'' |
| Q25L110 | 15.86G | 158.6 |     135 |   43 | 12.95G |  18.314% |  100M | 218.22M |     2.18 | 354.46M |     0 | 3:10'47'' |
| Q25L120 | 14.49G | 144.9 |     142 |   49 | 11.88G |  17.964% |  100M |  209.6M |     2.10 | 330.14M |     0 | 2:39'55'' |
| Q25L130 | 12.98G | 129.8 |     147 |   49 | 10.69G |  17.671% |  100M | 199.98M |     2.00 | 301.06M |     0 | 2:19'39'' |
| Q25L140 | 11.74G | 117.4 |     149 |   49 |   9.7G |  17.388% |  100M | 191.77M |     1.92 | 279.27M |     0 | 2:10'17'' |
| Q25L150 |    11G | 110.0 |     150 |   49 |  9.09G |  17.352% |  100M | 186.37M |     1.86 | 267.38M |     0 | 1:58'25'' |
| Q30L100 |  14.1G | 141.0 |     126 |   37 | 11.94G |  15.287% |  100M |  206.2M |     2.06 | 312.13M |     0 | 2:49'12'' |
| Q30L110 | 12.83G | 128.3 |     135 |   43 |  10.9G |  15.086% |  100M | 197.99M |     1.98 | 294.07M |     0 | 2:36'06'' |
| Q30L120 | 11.12G | 111.2 |     142 |   49 |  9.45G |  15.013% |  100M | 186.86M |     1.87 | 267.63M |     0 | 2:18'44'' |
| Q30L130 |  9.35G |  93.5 |     148 |   49 |  7.94G |  15.020% |  100M | 174.63M |     1.75 | 239.81M |     0 | 2:00'53'' |
| Q30L140 |  7.91G |  79.1 |     149 |   49 |  6.73G |  15.006% |  100M |  163.8M |     1.64 |    218M |     0 | 1:46'04'' |
| Q30L150 |  7.03G |  70.3 |     150 |   49 |  5.97G |  15.142% |  100M | 156.09M |     1.56 |  203.9M |     0 | 1:26'21'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|------:|-----:|----------:|--------:|--------:|----------:|
| Q20L100 |         97 | 432.23M | 4861858 |      6161 | 118.17M | 29266 |       1395 |  2.8M | 1964 |        60 | 311.26M | 4830628 | 1:57'35'' |
| Q20L110 |        116 | 424.17M | 4099420 |      7487 |  122.2M | 27872 |       1384 |  2.5M | 1762 |        69 | 299.47M | 4069786 | 1:57'37'' |
| Q20L120 |        142 | 397.88M | 3516838 |      8143 | 122.68M | 26957 |       1392 | 2.54M | 1788 |        75 | 272.66M | 3488093 | 1:48'03'' |
| Q20L130 |        150 | 370.17M | 2971857 |      8948 | 122.28M | 26079 |       1386 | 2.57M | 1822 |        83 | 245.31M | 2943956 | 1:33'18'' |
| Q20L140 |        166 | 348.53M | 2664451 |      9272 | 121.11M | 25435 |       1385 | 2.68M | 1900 |        87 | 224.73M | 2637116 | 1:12'32'' |
| Q20L150 |        195 | 326.72M | 2399598 |      9849 |  118.5M | 24168 |       1384 | 2.69M | 1913 |        90 | 205.54M | 2373517 | 1:07'40'' |
| Q25L100 |        150 | 367.05M | 3829734 |      6274 | 120.63M | 29279 |       1372 | 2.61M | 1852 |        63 | 243.81M | 3798603 | 1:17'23'' |
| Q25L110 |        155 | 354.46M | 3108371 |      8079 | 123.89M | 26710 |       1370 | 2.36M | 1685 |        74 | 228.21M | 3079976 | 1:15'22'' |
| Q25L120 |        201 | 330.14M | 2409099 |     10088 | 122.42M | 24034 |       1365 | 2.37M | 1710 |        89 | 205.35M | 2383355 | 1:04'53'' |
| Q25L130 |        272 | 301.06M | 2029445 |     11057 | 118.35M | 22491 |       1355 | 2.54M | 1831 |        97 | 180.18M | 2005123 | 0:55'43'' |
| Q25L140 |        372 | 279.27M | 1763264 |     11535 | 114.46M | 20983 |       1336 |  2.5M | 1820 |        97 | 162.31M | 1740461 | 0:51'09'' |
| Q25L150 |        436 | 267.38M | 1635555 |     11857 | 111.88M | 20107 |       1343 | 2.45M | 1783 |        97 | 153.05M | 1613665 | 0:46'26'' |
| Q30L100 |        235 | 312.13M | 2857620 |      7042 | 117.94M | 26790 |       1353 | 2.39M | 1723 |        71 | 191.81M | 2829107 | 1:05'12'' |
| Q30L110 |        312 | 294.07M | 2205398 |      9529 | 118.67M | 23831 |       1342 | 2.23M | 1617 |        85 | 173.17M | 2179950 | 1:00'43'' |
| Q30L120 |        468 | 267.63M | 1632437 |     12540 | 114.42M | 20395 |       1313 | 2.07M | 1534 |        97 | 151.15M | 1610508 | 0:47'17'' |
| Q30L130 |        659 | 239.81M | 1325078 |     12712 | 108.26M | 18724 |       1341 | 1.93M | 1417 |       104 | 129.62M | 1304937 | 0:51'13'' |
| Q30L140 |        831 |    218M | 1108274 |     12624 | 102.86M | 17537 |       1340 | 1.88M | 1371 |       118 | 113.25M | 1089366 | 0:23'44'' |
| Q30L150 |        990 |  203.9M |  981294 |     12634 |  99.34M | 16905 |       1331 | 1.76M | 1277 |       125 |  102.8M |  963112 | 0:22'02'' |

## F295: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L110/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L130/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q20L150/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L110/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L130/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q25L150/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L110/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L130/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q30L150/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L110/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L130/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q20L150/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L110/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L130/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q25L150/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L110/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L130/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    Q30L150/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# F340, Zygnema extenue, 亚小双星藻

## F340: download

```bash
mkdir -p ~/data/dna-seq/chara/F340/2_illumina
cd ~/data/dna-seq/chara/F340/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_2.clean.fq.gz R2.fq.gz
```

## F340: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 18309410400 | 122062736 |
| scythe   | 150 | 18294244113 | 122062736 |
| Q20L100  | 150 | 15952654843 | 108933506 |
| Q20L110  | 150 | 15395740729 | 104516894 |
| Q20L120  | 150 | 14568381351 |  98229518 |
| Q20L130  | 150 | 13469698389 |  90200814 |
| Q20L140  | 150 | 12635988723 |  84308072 |
| Q20L150  | 150 | 11252441400 |  75016276 |
| Q25L100  | 150 | 13578669804 |  94126722 |
| Q25L110  | 150 | 12804749796 |  87963032 |
| Q25L120  | 150 | 11635292163 |  79059322 |
| Q25L130  | 150 | 10116885486 |  67957746 |
| Q25L140  | 150 |  8937530416 |  59628052 |
| Q25L150  | 150 |  8133527700 |  54223518 |
| Q30L100  | 150 | 10568914263 |  74892562 |
| Q30L110  | 150 |  9554392799 |  66795324 |
| Q30L120  | 150 |  8068144811 |  55466460 |
| Q30L130  | 150 |  6316882890 |  42652592 |
| Q30L140  | 150 |  5054092292 |  33733744 |
| Q30L150  | 150 |  4283448000 |  28556320 |


## F340: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F340: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F340: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F340: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 15.95G | 159.5 |     139 |   67 | 12.19G |  23.579% |  100M |  388.1M |     3.88 | 722.21M |     0 | 2:54'42'' |
| Q20L110 |  15.4G | 154.0 |     140 |   67 |  11.8G |  23.352% |  100M |  377.5M |     3.77 | 688.88M |     0 | 2:50'04'' |
| Q20L120 | 14.57G | 145.7 |     145 |   75 |  11.2G |  23.113% |  100M | 362.68M |     3.63 | 646.49M |     0 | 2:27'20'' |
| Q20L130 | 13.47G | 134.7 |     148 |   75 | 10.38G |  22.928% |  100M | 344.06M |     3.44 | 590.89M |     0 | 2:07'18'' |
| Q20L140 | 12.64G | 126.4 |     149 |   75 |  9.75G |  22.816% |  100M | 329.52M |     3.30 | 551.31M |     0 | 2:07'57'' |
| Q20L150 | 11.25G | 112.5 |     150 |   75 |  8.63G |  23.292% |  100M | 293.26M |     2.93 | 476.36M |     0 | 1:44'52'' |
| Q25L100 | 13.58G | 135.8 |     136 |   67 | 10.98G |  19.151% |  100M | 339.23M |     3.39 |  549.7M |     0 | 2:32'20'' |
| Q25L110 |  12.8G | 128.0 |     137 |   69 | 10.34G |  19.224% |  100M | 325.52M |     3.26 | 518.99M |     0 | 2:21'06'' |
| Q25L120 | 11.64G | 116.4 |     143 |   75 |  9.37G |  19.457% |  100M | 305.57M |     3.06 | 476.49M |     0 | 1:42'49'' |
| Q25L130 | 10.12G | 101.2 |     148 |   75 |  8.09G |  19.989% |  100M | 280.04M |     2.80 | 427.67M |     0 | 1:29'37'' |
| Q25L140 |  8.94G |  89.4 |     149 |   75 |   7.1G |  20.554% |  100M | 258.26M |     2.58 | 388.89M |     0 | 1:15'17'' |
| Q25L150 |  8.13G |  81.3 |     150 |   75 |  6.41G |  21.179% |  100M | 233.25M |     2.33 | 346.94M |     0 | 1:11'32'' |
| Q30L100 | 10.57G | 105.7 |     137 |   63 |  8.83G |  16.412% |  100M | 281.21M |     2.81 | 426.69M |     0 | 1:39'46'' |
| Q30L110 |  9.55G |  95.5 |     138 |   63 |  7.93G |  16.991% |  100M | 262.76M |     2.63 | 395.38M |     0 | 1:28'29'' |
| Q30L120 |  8.07G |  80.7 |     142 |   69 |  6.61G |  18.103% |  100M | 235.25M |     2.35 |  347.6M |     0 | 1:06'25'' |
| Q30L130 |  6.32G |  63.2 |     147 |   75 |  5.05G |  20.010% |  100M | 200.85M |     2.01 | 291.08M |     0 | 0:53'57'' |
| Q30L140 |  5.05G |  50.5 |     149 |   75 |  3.94G |  21.947% |  100M | 172.31M |     1.72 | 246.29M |     0 | 0:42'41'' |
| Q30L150 |  4.28G |  42.8 |     150 |   75 |  3.28G |  23.325% |  100M | 142.26M |     1.42 | 199.24M |     0 | 0:37'57'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |    Sum |     # | N50Anchor2 |    Sum |    # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|-------:|------:|-----------:|-------:|-----:|----------:|--------:|--------:|----------:|
| Q20L100 |        157 | 722.21M | 4964977 |      3193 | 77.61M | 28454 |       1254 |  3.65M | 2821 |       142 | 640.96M | 4933702 | 2:17'39'' |
| Q20L110 |        164 | 688.88M | 4638838 |      3269 | 77.37M | 27876 |       1255 |  3.53M | 2721 |       149 | 607.98M | 4608241 | 2:08'13'' |
| Q20L120 |        173 | 646.49M | 3959872 |      3476 | 73.39M | 25493 |       1242 |  2.23M | 1746 |       150 | 570.86M | 3932633 | 1:58'55'' |
| Q20L130 |        184 | 590.89M | 3482916 |      3836 | 71.77M | 23731 |       1244 |  2.26M | 1762 |       154 | 516.86M | 3457423 | 1:42'10'' |
| Q20L140 |        191 | 551.31M | 3160707 |      4200 | 69.82M | 22166 |       1247 |  2.28M | 1768 |       159 |  479.2M | 3136773 | 1:22'14'' |
| Q20L150 |        191 | 476.36M | 2690562 |      5037 | 63.36M | 18520 |       1246 |  1.91M | 1482 |       160 | 411.09M | 2670560 | 1:06'26'' |
| Q25L100 |        207 |  549.7M | 3204098 |      4377 | 77.14M | 23943 |       1244 |  2.74M | 2127 |       166 | 469.82M | 3178028 | 1:28'35'' |
| Q25L110 |        212 | 518.99M | 2912810 |      4779 | 74.08M | 22203 |       1243 |  2.48M | 1934 |       171 | 442.43M | 2888673 | 1:24'22'' |
| Q25L120 |        212 | 476.49M | 2505930 |      5547 | 67.94M | 19189 |       1234 |  1.78M | 1396 |       176 | 406.77M | 2485345 | 1:15'12'' |
| Q25L130 |        217 | 427.67M | 2202909 |      6275 | 62.78M | 16998 |       1238 |  1.82M | 1427 |       180 | 363.07M | 2184484 | 1:06'11'' |
| Q25L140 |        219 | 388.89M | 1980761 |      6651 | 58.12M | 15545 |       1245 |  1.78M | 1385 |       181 |    329M | 1963831 | 0:58'27'' |
| Q25L150 |        216 | 346.94M | 1766230 |      7490 | 53.72M | 13674 |       1253 |  1.53M | 1186 |       178 | 291.69M | 1751370 | 0:48'39'' |
| Q30L100 |        227 | 426.69M | 2405291 |      6585 | 67.92M | 18525 |       1263 |  2.18M | 1672 |       177 | 356.59M | 2385094 | 1:27'31'' |
| Q30L110 |        229 | 395.38M | 2208238 |      6862 | 64.65M | 17576 |       1269 |  2.32M | 1771 |       177 | 328.42M | 2188891 | 1:16'57'' |
| Q30L120 |        226 |  347.6M | 1813370 |      6557 | 58.74M | 16133 |       1257 |  1.78M | 1367 |       179 | 287.09M | 1795870 | 1:04'19'' |
| Q30L130 |        218 | 291.08M | 1453024 |      8812 |  49.2M | 12561 |       1259 |  1.37M | 1062 |       177 | 240.51M | 1439401 | 0:56'13'' |
| Q30L140 |        217 | 246.29M | 1221742 |     10825 |  43.3M |  9677 |       1253 |   1.2M |  939 |       175 | 201.78M | 1211126 | 0:17'31'' |
| Q30L150 |        216 | 199.24M |  975822 |     10508 |  39.9M |  8060 |       1245 | 852.8K |  668 |       169 | 158.48M |  967094 | 0:13'44'' |

## F340: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L110/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L130/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q20L150/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L110/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L130/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q25L150/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L110/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L130/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q30L150/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L110/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L130/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q20L150/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L110/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L130/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q25L150/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L110/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L130/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    Q30L150/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# F354, Spirogyra gracilis, 纤细水绵

转录本杂合度 0.35%

## F354: download

```bash
mkdir -p ~/data/dna-seq/chara/F354/2_illumina
cd ~/data/dna-seq/chara/F354/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

## F354: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 18458643300 | 123057622 |
| scythe   | 150 | 18443254985 | 123057622 |
| Q20L100  | 150 | 16664961072 | 113346788 |
| Q20L110  | 150 | 16159310690 | 109306224 |
| Q20L120  | 150 | 15445257362 | 103851406 |
| Q20L130  | 150 | 14601327634 |  97671856 |
| Q20L140  | 150 | 13893582835 |  92670244 |
| Q20L150  | 150 | 13293153900 |  88621026 |
| Q25L100  | 150 | 15021258383 | 103361408 |
| Q25L110  | 150 | 14303481931 |  97595068 |
| Q25L120  | 150 | 13270350197 |  89684292 |
| Q25L130  | 150 | 12091906908 |  81047256 |
| Q25L140  | 150 | 11083452302 |  73924922 |
| Q25L150  | 150 | 10725994800 |  71506632 |
| Q30L100  | 150 | 12888727658 |  90110112 |
| Q30L110  | 150 | 11936866896 |  82432740 |
| Q30L120  | 150 | 10588694224 |  72090510 |
| Q30L130  | 150 |  9129547572 |  61387178 |
| Q30L140  | 150 |  7895806241 |  52674272 |
| Q30L150  | 150 |  7571910600 |  50479404 |

## F354: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F354: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F354: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F354: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 16.66G | 166.6 |     130 |   41 |  13.9G |  16.585% |  100M | 111.86M |     1.12 | 139.56M |     0 | 4:53'13'' |
| Q20L110 | 16.16G | 161.6 |     138 |   43 | 13.59G |  15.923% |  100M | 110.54M |     1.11 | 136.29M |     0 | 4:56'53'' |
| Q20L120 | 15.45G | 154.5 |     144 |   49 | 13.11G |  15.140% |  100M | 108.81M |     1.09 | 132.99M |     0 | 4:28'47'' |
| Q20L130 |  14.6G | 146.0 |     147 |   49 | 12.51G |  14.335% |  100M | 106.69M |     1.07 | 127.68M |     0 | 2:07'24'' |
| Q20L140 | 13.89G | 138.9 |     149 |   49 |    12G |  13.649% |  100M |  104.8M |     1.05 | 123.43M |     0 | 2:50'29'' |
| Q20L150 | 13.29G | 132.9 |     150 |   49 | 11.53G |  13.278% |  100M | 103.65M |     1.04 | 120.97M |     0 | 2:38'45'' |
| Q25L100 | 15.02G | 150.2 |     128 |   39 | 13.32G |  11.356% |  100M | 107.16M |     1.07 | 124.18M |     0 | 2:24'22'' |
| Q25L110 |  14.3G | 143.0 |     135 |   43 | 12.74G |  10.903% |  100M | 105.29M |     1.05 | 120.94M |     0 | 2:07'02'' |
| Q25L120 | 13.27G | 132.7 |     142 |   49 | 11.89G |  10.406% |  100M | 102.67M |     1.03 | 116.79M |     0 | 2:02'02'' |
| Q25L130 | 12.09G | 120.9 |     147 |   49 | 10.89G |   9.946% |  100M |  99.25M |     0.99 | 111.37M |     0 | 1:41'19'' |
| Q25L140 | 11.08G | 110.8 |     149 |   49 | 10.03G |   9.515% |  100M |  95.93M |     0.96 | 106.46M |     0 | 1:35'49'' |
| Q25L150 | 10.73G | 107.3 |     150 |   49 |  9.72G |   9.410% |  100M |   95.1M |     0.95 | 105.27M |     0 | 1:39'03'' |
| Q30L100 | 12.89G | 128.9 |     127 |   39 | 11.89G |   7.719% |  100M | 101.68M |     1.02 | 113.33M |     0 | 1:51'32'' |
| Q30L110 | 11.94G | 119.4 |     134 |   45 | 11.05G |   7.451% |  100M |   98.7M |     0.99 | 109.13M |     0 | 1:37'41'' |
| Q30L120 | 10.59G | 105.9 |     143 |   49 |  9.82G |   7.214% |  100M |  94.17M |     0.94 | 102.72M |     0 | 1:24'15'' |
| Q30L130 |  9.13G |  91.3 |     147 |   49 |  8.49G |   6.992% |  100M |  88.73M |     0.89 |  95.96M |     0 | 1:15'19'' |
| Q30L140 |   7.9G |  79.0 |     149 |   49 |  7.36G |   6.734% |  100M |   83.5M |     0.84 |  89.61M |     0 | 1:04'34'' |
| Q30L150 |  7.57G |  75.7 |     150 |   49 |  7.06G |   6.699% |  100M |  82.42M |     0.82 |  88.32M |     0 | 1:01'19'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |    Sum |     # | N50Anchor2 |     Sum |    # | N50Others |    Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|-------:|------:|-----------:|--------:|-----:|----------:|-------:|-------:|----------:|
| Q20L100 |        919 | 139.56M | 665871 |      3011 | 62.73M | 23827 |       1407 |   3.34M | 2330 |       205 | 73.49M | 639714 | 1:21'46'' |
| Q20L110 |       1011 | 136.29M | 590207 |      3201 | 64.09M | 23378 |       1409 |   3.29M | 2285 |       224 | 68.91M | 564544 | 1:25'06'' |
| Q20L120 |       1105 | 132.99M | 491071 |      3655 | 65.53M | 22346 |       1364 |   2.96M | 2114 |       247 | 64.51M | 466611 | 1:30'45'' |
| Q20L130 |       1247 | 127.68M | 430044 |      4163 | 66.29M | 21339 |       1363 |   2.99M | 2140 |       272 |  58.4M | 406565 | 1:42'08'' |
| Q20L140 |       1372 | 123.43M | 385127 |      4608 | 66.68M | 20398 |       1349 |   2.84M | 2053 |       289 | 53.91M | 362676 | 1:05'32'' |
| Q20L150 |       1447 | 120.97M | 360368 |      5088 | 66.64M | 19432 |       1345 |   2.67M | 1940 |       300 | 51.65M | 338996 | 0:50'47'' |
| Q25L100 |       1522 | 124.18M | 432201 |      3656 | 70.71M | 23800 |       1372 |    2.7M | 1920 |       275 | 50.77M | 406481 | 1:10'02'' |
| Q25L110 |       1677 | 120.94M | 362771 |      4485 | 71.04M | 21613 |       1352 |   2.65M | 1914 |       295 | 47.25M | 339244 | 1:00'30'' |
| Q25L120 |       1864 | 116.79M | 295750 |      6197 | 69.63M | 18356 |       1328 |   2.46M | 1807 |       321 |  44.7M | 275587 | 0:39'02'' |
| Q25L130 |       2234 | 111.37M | 258542 |      7520 | 67.58M | 15765 |       1328 |   2.23M | 1646 |       336 | 41.56M | 241131 | 0:34'28'' |
| Q25L140 |       2804 | 106.46M | 228865 |      8767 | 65.69M | 13675 |       1311 |   1.86M | 1378 |       344 | 38.91M | 213812 | 0:57'57'' |
| Q25L150 |       3064 | 105.27M | 222120 |      9213 | 65.19M | 13019 |       1298 |   1.77M | 1328 |       345 | 38.31M | 207773 | 0:38'46'' |
| Q30L100 |       2152 | 113.33M | 298795 |      5517 | 70.53M | 19006 |       1348 |   2.19M | 1591 |       327 | 40.61M | 278198 | 1:00'33'' |
| Q30L110 |       2783 | 109.13M | 239357 |      8178 | 68.64M | 15028 |       1306 |   1.95M | 1446 |       346 | 38.53M | 222883 | 0:50'41'' |
| Q30L120 |       5390 | 102.72M | 190505 |     13618 | 65.65M | 10181 |       1283 |   1.47M | 1116 |       355 |  35.6M | 179208 | 0:39'55'' |
| Q30L130 |       6841 |  95.96M | 165218 |     14680 | 62.64M |  8318 |       1282 |   1.07M |  819 |       349 | 32.25M | 156081 | 0:27'49'' |
| Q30L140 |       8012 |  89.61M | 142658 |     15000 | 60.94M |  7440 |       1261 | 676.29K |  520 |       330 |    28M | 134698 | 0:27'49'' |
| Q30L150 |       8292 |  88.32M | 138329 |     15812 |  60.6M |  7243 |       1257 | 614.66K |  470 |       325 | 27.11M | 130616 | 0:25'04'' |

## F354: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L110/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L130/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q20L150/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L110/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L130/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q25L150/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L110/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L130/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q30L150/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L110/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L130/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q20L150/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L110/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L130/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q25L150/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L110/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L130/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    Q30L150/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# F357, Botryococcus braunii, 布朗葡萄藻

## F357: download

```bash
mkdir -p ~/data/dna-seq/chara/F357/2_illumina
cd ~/data/dna-seq/chara/F357/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_2.clean.fq.gz R2.fq.gz
```

## F357: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 22137245100 | 147581634 |
| scythe   | 150 | 22118027725 | 147581634 |
| Q20L100  | 150 | 20057032788 | 136342436 |
| Q20L110  | 150 | 19498376907 | 131899308 |
| Q20L120  | 150 | 18634968061 | 125322730 |
| Q20L130  | 150 | 17607856611 | 117809388 |
| Q20L140  | 150 | 16750611034 | 111750502 |
| Q20L150  | 150 | 15344110200 | 102294068 |
| Q25L100  | 150 | 17902265759 | 123580816 |
| Q25L110  | 150 | 17001924841 | 116396528 |
| Q25L120  | 150 | 15566299109 | 105446988 |
| Q25L130  | 150 | 13932322162 |  93486370 |
| Q25L140  | 150 | 12550039192 |  83723014 |
| Q25L150  | 150 | 11680965000 |  77873100 |
| Q30L100  | 150 | 14755783068 | 104332352 |
| Q30L110  | 150 | 13374051421 |  93283966 |
| Q30L120  | 150 | 11301578353 |  77453366 |
| Q30L130  | 150 |  9183337817 |  61931624 |
| Q30L140  | 150 |  7535388011 |  50290238 |
| Q30L150  | 150 |  6597225000 |  43981500 |

## F357: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F357: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F357: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F357: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 20.06G | 200.6 |     139 |   45 | 16.43G |  18.086% |  100M | 271.47M |     2.71 | 374.46M |     0 | 4:48'32'' |
| Q20L110 |  19.5G | 195.0 |     140 |   49 | 16.06G |  17.640% |  100M | 266.83M |     2.67 | 365.61M |     0 | 4:44'33'' |
| Q20L120 | 18.63G | 186.3 |     143 |   49 | 15.46G |  17.062% |  100M | 260.54M |     2.61 | 347.71M |     0 | 4:37'26'' |
| Q20L130 | 17.61G | 176.1 |     148 |   49 | 14.71G |  16.443% |  100M | 253.51M |     2.54 | 329.57M |     0 | 3:39'55'' |
| Q20L140 | 16.75G | 167.5 |     149 |   49 | 14.08G |  15.930% |  100M | 247.76M |     2.48 |    316M |     0 | 3:30'44'' |
| Q20L150 | 15.34G | 153.4 |     150 |   49 | 12.95G |  15.587% |  100M | 238.12M |     2.38 | 298.02M |     0 | 3:04'46'' |
| Q25L100 |  17.9G | 179.0 |     136 |   45 | 15.64G |  12.626% |  100M |  254.4M |     2.54 | 316.95M |     0 | 5:28'08'' |
| Q25L110 |    17G | 170.0 |     138 |   49 | 14.91G |  12.317% |  100M | 248.46M |     2.48 | 307.23M |     0 | 9:58'32'' |
| Q25L120 | 15.57G | 155.7 |     142 |   49 | 13.71G |  11.948% |  100M | 239.86M |     2.40 | 291.47M |     0 | 7:46'31'' |
| Q25L130 | 13.93G | 139.3 |     148 |   49 | 12.31G |  11.645% |  100M | 229.66M |     2.30 | 274.58M |     0 | 6:20'59'' |
| Q25L140 | 12.55G | 125.5 |     149 |   49 | 11.12G |  11.388% |  100M | 220.37M |     2.20 | 260.27M |     0 | 4:14'46'' |
| Q25L150 | 11.68G | 116.8 |     150 |   49 | 10.35G |  11.355% |  100M | 212.83M |     2.13 | 249.65M |     0 | 6:02'17'' |
| Q30L100 | 14.76G | 147.6 |     134 |   43 |  13.5G |   8.477% |  100M | 233.45M |     2.33 | 274.84M |     0 | 7:36'48'' |
| Q30L110 | 13.37G | 133.7 |     137 |   43 | 12.25G |   8.388% |  100M | 224.47M |     2.24 | 261.86M |     0 | 7:12'56'' |
| Q30L120 |  11.3G | 113.0 |     142 |   45 | 10.36G |   8.328% |  100M | 210.81M |     2.11 | 243.57M |     0 | 5:01'12'' |
| Q30L130 |  9.18G |  91.8 |     147 |   49 |  8.41G |   8.446% |  100M | 194.64M |     1.95 | 222.92M |     0 | 5:38'56'' |
| Q30L140 |  7.54G |  75.4 |     149 |   49 |  6.89G |   8.620% |  100M | 179.87M |     1.80 | 204.02M |     0 | 1:31'37'' |
| Q30L150 |   6.6G |  66.0 |     150 |   49 |  6.01G |   8.940% |  100M | 167.46M |     1.67 | 188.37M |     0 | 1:05'17'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|------:|-----:|----------:|--------:|--------:|----------:|
| Q20L100 |        427 | 374.46M | 2273859 |      5330 | 113.74M | 33896 |       1324 | 7.46M | 5487 |       150 | 253.26M | 2234476 | 2:09'29'' |
| Q20L110 |        445 | 365.61M | 2016280 |      6338 | 113.86M | 31917 |       1314 |  6.7M | 4978 |       158 | 245.05M | 1979385 | 2:10'51'' |
| Q20L120 |        489 | 347.71M | 1787825 |      6851 | 113.34M | 30906 |       1312 | 6.38M | 4746 |       179 | 227.99M | 1752173 | 2:13'48'' |
| Q20L130 |        534 | 329.57M | 1570439 |      7404 | 112.49M | 29721 |       1314 | 6.02M | 4471 |       203 | 211.06M | 1536247 | 2:10'48'' |
| Q20L140 |        567 |    316M | 1418035 |      8024 | 111.43M | 28468 |       1312 | 5.74M | 4264 |       222 | 198.82M | 1385303 | 1:57'47'' |
| Q20L150 |        579 | 298.02M | 1260836 |      9072 | 107.96M | 25466 |       1309 | 4.71M | 3514 |       240 | 185.36M | 1231856 | 1:56'01'' |
| Q25L100 |        637 | 316.95M | 1395105 |      6598 | 118.47M | 32547 |       1301 | 5.97M | 4451 |       241 | 192.51M | 1358107 | 2:57'38'' |
| Q25L110 |        652 | 307.23M | 1223931 |      8325 | 117.49M | 29623 |       1294 | 5.23M | 3929 |       254 | 184.52M | 1190379 | 2:43'37'' |
| Q25L120 |        687 | 291.47M | 1086511 |      8959 | 115.21M | 27617 |       1289 | 4.79M | 3614 |       275 | 171.48M | 1055280 | 2:02'37'' |
| Q25L130 |        723 | 274.58M |  958826 |      9527 | 112.46M | 25413 |       1283 |  4.1M | 3090 |       293 | 158.03M |  930323 | 2:43'20'' |
| Q25L140 |        756 | 260.27M |  862821 |      9781 | 110.58M | 23755 |       1278 |  3.4M | 2586 |       301 | 146.29M |  836480 | 2:10'07'' |
| Q25L150 |        770 | 249.65M |  806089 |      9947 | 108.58M | 22136 |       1277 | 2.74M | 2089 |       299 | 138.33M |  781864 | 1:30'21'' |
| Q30L100 |        812 | 274.84M |  984409 |      7848 | 118.95M | 29308 |       1275 | 4.14M | 3151 |       305 | 151.76M |  951950 | 1:45'49'' |
| Q30L110 |        848 | 261.86M |  896141 |      8176 | 116.63M | 27443 |       1278 |  3.7M | 2820 |       311 | 141.53M |  865878 | 3:06'55'' |
| Q30L120 |        913 | 243.57M |  768179 |      8965 | 113.69M | 24220 |       1272 | 2.79M | 2139 |       307 | 127.09M |  741820 | 2:51'01'' |
| Q30L130 |       1068 | 222.92M |  637618 |     10096 | 110.15M | 20533 |       1287 | 1.93M | 1459 |       292 | 110.84M |  615626 | 2:02'23'' |
| Q30L140 |       1405 | 204.02M |  555003 |     10255 | 105.38M | 18961 |       1315 | 1.79M | 1317 |       282 |  96.85M |  534725 | 1:35'41'' |
| Q30L150 |       1851 | 188.37M |  489136 |     10867 | 101.83M | 17841 |       1332 | 1.61M | 1176 |       269 |  84.93M |  470119 | 0:40'29'' |

## F357: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L110/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L130/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q20L150/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L110/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L130/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q25L150/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L110/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L130/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q30L150/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L110/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L130/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q20L150/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L110/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L130/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q25L150/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L110/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L130/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    Q30L150/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# F1084, Staurastrum sp., 角星鼓藻

## F1084: download

```bash
mkdir -p ~/data/dna-seq/chara/F1084/2_illumina
cd ~/data/dna-seq/chara/F1084/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

## F1084: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 17281584900 | 115210566 |
| scythe   | 150 | 17261000395 | 115210566 |
| Q20L100  | 150 | 15161745056 | 103258116 |
| Q20L110  | 150 | 14647919244 |  99152642 |
| Q20L120  | 150 | 13955343242 |  93863690 |
| Q20L130  | 150 | 13153734493 |  87996026 |
| Q20L140  | 150 | 12488958494 |  83298866 |
| Q20L150  | 150 | 11929291800 |  79528612 |
| Q25L100  | 150 | 13518104483 |  93139660 |
| Q25L110  | 150 | 12818739515 |  87530538 |
| Q25L120  | 150 | 11845269250 |  80085712 |
| Q25L130  | 150 | 10749516310 |  72059806 |
| Q25L140  | 150 |  9819557896 |  65493092 |
| Q25L150  | 150 |  9497587200 |  63317248 |
| Q30L100  | 150 | 11447985724 |  80176260 |
| Q30L110  | 150 | 10536077835 |  72842562 |
| Q30L120  | 150 |  9283140008 |  63246966 |
| Q30L130  | 150 |  7944322353 |  53433794 |
| Q30L140  | 150 |  6826534356 |  45541478 |
| Q30L150  | 150 |  6501972300 |  43346482 |

## F1084: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F1084: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F1084: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F1084: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 15.16G | 151.6 |     132 |   63 | 12.42G |  18.074% |  100M | 167.85M |     1.68 | 250.28M |     0 | 3:42'09'' |
| Q20L110 | 14.65G | 146.5 |     139 |   67 |  12.1G |  17.395% |  100M | 166.78M |     1.67 | 245.08M |     0 | 3:37'06'' |
| Q20L120 | 13.96G | 139.6 |     145 |   75 | 11.64G |  16.601% |  100M | 165.47M |     1.65 | 239.82M |     0 | 3:34'33'' |
| Q20L130 | 13.15G | 131.5 |     148 |   75 | 11.08G |  15.765% |  100M | 164.11M |     1.64 | 233.13M |     0 | 3:51'47'' |
| Q20L140 | 12.49G | 124.9 |     149 |   75 | 10.61G |  15.046% |  100M | 163.05M |     1.63 | 228.45M |     0 | 3:37'18'' |
| Q20L150 | 11.93G | 119.3 |     150 |   75 | 10.18G |  14.624% |  100M | 162.31M |     1.62 | 225.89M |     0 | 2:49'26'' |
| Q25L100 | 13.52G | 135.2 |     130 |   61 | 11.83G |  12.475% |  100M | 164.03M |     1.64 | 228.39M |     0 | 3:13'03'' |
| Q25L110 | 12.82G | 128.2 |     136 |   67 | 11.28G |  12.001% |  100M |  163.1M |     1.63 | 225.34M |     0 | 4:01'12'' |
| Q25L120 | 11.85G | 118.5 |     143 |   75 | 10.49G |  11.479% |  100M | 161.86M |     1.62 | 221.81M |     0 | 2:31'33'' |
| Q25L130 | 10.75G | 107.5 |     148 |   75 |  9.57G |  10.975% |  100M | 160.41M |     1.60 | 217.73M |     0 | 3:27'23'' |
| Q25L140 |  9.82G |  98.2 |     149 |   75 |  8.79G |  10.500% |  100M | 159.12M |     1.59 | 214.59M |     0 | 2:07'27'' |
| Q25L150 |   9.5G |  95.0 |     150 |   75 |  8.51G |  10.374% |  100M | 158.69M |     1.59 |  213.7M |     0 | 2:13'39'' |
| Q30L100 | 11.45G | 114.5 |     128 |   61 | 10.47G |   8.537% |  100M | 161.07M |     1.61 | 217.63M |     0 | 2:42'46'' |
| Q30L110 | 10.54G | 105.4 |     136 |   75 |  9.67G |   8.232% |  100M | 160.01M |     1.60 | 215.77M |     0 | 2:17'18'' |
| Q30L120 |  9.28G |  92.8 |     143 |   75 |  8.55G |   7.930% |  100M | 158.38M |     1.58 |  212.5M |     0 | 2:00'17'' |
| Q30L130 |  7.94G |  79.4 |     148 |   75 |  7.34G |   7.650% |  100M | 156.37M |     1.56 | 208.93M |     0 | 1:17'35'' |
| Q30L140 |  6.83G |  68.3 |     149 |   75 |  6.32G |   7.348% |  100M | 154.25M |     1.54 |  205.6M |     0 | 0:58'03'' |
| Q30L150 |   6.5G |  65.0 |     150 |   75 |  6.03G |   7.299% |  100M | 153.63M |     1.54 | 204.69M |     0 | 0:54'49'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |     Sum |   # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|--------:|----:|----------:|--------:|--------:|----------:|
| Q20L100 |        450 | 250.28M | 1157914 |      5138 | 100.06M | 28363 |       1293 | 337.35K | 254 |       136 | 149.88M | 1129297 | 1:04'03'' |
| Q20L110 |        545 | 245.08M | 1020555 |      5231 | 103.42M | 29041 |       1265 |    313K | 240 |       149 | 141.35M |  991274 | 1:05'53'' |
| Q20L120 |        703 | 239.82M |  850707 |      5167 | 108.75M | 30566 |       1254 | 270.85K | 211 |       164 |  130.8M |  819930 | 1:01'47'' |
| Q20L130 |        808 | 233.13M |  781983 |      5111 | 109.48M | 30822 |       1244 | 291.44K | 229 |       173 | 123.36M |  750932 | 1:09'21'' |
| Q20L140 |        887 | 228.45M |  735770 |      5080 | 109.85M | 31030 |       1245 |  317.5K | 246 |       180 | 118.28M |  704494 | 0:44'34'' |
| Q20L150 |        937 | 225.89M |  711490 |      5041 | 110.17M | 31171 |       1245 | 298.23K | 229 |       183 | 115.43M |  680090 | 0:51'54'' |
| Q25L100 |        695 | 228.39M |  909717 |      5461 | 102.73M | 28483 |       1261 | 286.17K | 220 |       155 | 125.37M |  881014 | 1:03'46'' |
| Q25L110 |        852 | 225.34M |  784759 |      5416 | 107.22M | 29609 |       1267 | 246.66K | 192 |       170 | 117.87M |  754958 | 1:00'28'' |
| Q25L120 |       1070 | 221.81M |  661637 |      5080 | 112.18M | 31369 |       1272 | 237.72K | 182 |       188 | 109.39M |  630086 | 0:46'42'' |
| Q25L130 |       1144 | 217.73M |  629485 |      4919 |    112M | 31704 |       1235 | 288.87K | 223 |       192 | 105.45M |  597558 | 0:42'04'' |
| Q25L140 |       1190 | 214.59M |  607279 |      4815 | 111.43M | 31941 |       1249 | 401.45K | 310 |       195 | 102.76M |  575028 | 0:41'51'' |
| Q25L150 |       1203 |  213.7M |  601543 |      4784 | 111.24M | 31947 |       1263 | 439.83K | 338 |       196 | 102.02M |  569258 | 0:33'30'' |
| Q30L100 |        910 | 217.63M |  786399 |      5698 | 105.52M | 28378 |       1243 |  232.1K | 182 |       164 | 111.88M |  757839 | 0:53'32'' |
| Q30L110 |       1254 | 215.77M |  607597 |      5076 | 113.63M | 31511 |       1240 | 207.95K | 162 |       192 | 101.94M |  575924 | 0:49'42'' |
| Q30L120 |       1271 |  212.5M |  588782 |      4875 | 112.23M | 31743 |       1239 |    302K | 237 |       196 |  99.96M |  556802 | 0:43'25'' |
| Q30L130 |       1241 | 208.93M |  572911 |      4659 |  109.6M | 31920 |       1251 | 561.04K | 433 |       202 |  98.77M |  540558 | 0:31'20'' |
| Q30L140 |       1182 |  205.6M |  562468 |      4408 | 106.26M | 32166 |       1283 | 910.09K | 695 |       207 |  98.43M |  529607 | 0:26'47'' |
| Q30L150 |       1161 | 204.69M |  560316 |      4284 | 105.15M | 32192 |       1278 |      1M | 763 |       209 |  98.54M |  527361 | 0:25'51'' |

## F1084: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L110/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L130/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q20L150/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L110/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L130/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q25L150/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L110/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L130/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q30L150/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L110/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L130/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q20L150/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L110/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L130/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q25L150/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L110/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L130/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    Q30L150/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# moli, 茉莉

SR had failed twice due to the calculating results from awk were larger
than the MAX_INT

* for jellyfish
* for --number-reads of
  `getSuperReadInsertCountsFromReadPlacementFileTwoPasses`

```bash
mkdir -p /home/wangq/zlc/medfood/superreads/moli
cd ~/zlc/medfood/superreads/moli

perl ~/Scripts/sra/superreads.pl \
    ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000 --kmer 77
```

```bash
mkdir -p /home/wangq/zlc/medfood/superreads/moli_sub
cd ~/zlc/medfood/superreads/moli_sub

# 200 M Reads
zcat ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    | head -n 800000000 \
    | gzip > R1.fq.gz

zcat ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    | head -n 800000000 \
    | gzip > R2.fq.gz

perl ~/Scripts/sra/superreads.pl \
    R1.fq.gz \
    R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000
```

# Summary of SR

| Name     | fq size | fa size | Length | Kmer | Est. Genome |   Run time |     Sum SR | SR/Est.G |
|:---------|--------:|--------:|-------:|-----:|------------:|-----------:|-----------:|---------:|
| F63      |   33.9G |     19G |    150 |   49 |   345627684 |  4:04'22'' |  697371843 |     2.02 |
| F295     |   43.3G |     24G |    150 |   49 |   452975652 |  6:01'13'' |  742260051 |     1.64 |
| F340     |   35.9G |     20G |    150 |   75 |   566603922 |  3:21'01'' |  852873811 |     1.51 |
| F354     |   36.2G |     20G |    150 |   49 |   133802786 |  6:06'09'' |  351863887 |     2.63 |
| F357     |   43.5G |     24G |    150 |   49 |   338905264 |  5:41'49'' |  796466152 |     2.35 |
| F1084    |   33.9G |     19G |    150 |   75 |   199395661 |  4:32'01'' |  570760287 |     2.86 |
| moli_sub |    118G |     63G |    150 |  105 |   608561446 | 11:29'38'' | 2899953305 |     4.77 |

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
        printf "%d:%02d'%02d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) ) \
    $( faops n50 -H -N 0 -S work1/superReadSequences.fasta)

```

Thoughts:

* kmer 与污染的关系还不好说
* kmer 估计基因组比真实的大得越多, 污染就越多
* 有多个因素会影响 SR/Est.G. 细菌与单倍体会趋向于 2, paralog 与杂合会趋向于 4.
* 50 倍的二代数据并不充分, 与 100 倍之间还是有明显的差异的. 覆盖数不够也会导致
  SR/Est.G 低于真实值.

# Anchors

```bash

cd sr
faops n50 -N 50 -S -C superReadSequences.fasta
faops n50 -N 0 -C pe.cor.fa
faops n50 -N 0 -C pe.strict.fa

printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
    $( basename $( dirname $(pwd) ) ) \
    $( faops n50 -H -N 50 -S -C pe.anchor.fa) \
    $( faops n50 -H -N 50 -S -C pe.anchor2.fa) \
    $( faops n50 -H -N 50 -S -C pe.others.fa)

```

| Name  | N50 SR |    Sum SR |     #SR |   #cor.fa | #strict.fa |
|:------|-------:|----------:|--------:|----------:|-----------:|
| F63   |   1815 | 697371843 |  986675 | 115078314 |   94324950 |
| F295  |    477 | 742260051 | 1975444 | 146979656 |  119415569 |
| F340  |    388 | 852873811 | 2383927 | 122062736 |  102014388 |
| F354  |    768 | 351863887 |  584408 | 123057622 |  106900181 |
| F357  |    599 | 796466152 | 1644428 | 147581634 |  129353409 |
| F1084 |    893 | 570760287 |  882123 | 115210566 |   97481899 |

| Name  |  N50 |      Sum | #anchor | N50 | Sum | #anchor2 | N50 | Sum | #others |
|:------|-----:|---------:|--------:|----:|----:|---------:|----:|----:|--------:|
| F63   | 4003 | 52342433 |   21120 |     |     |          |     |     |         |
| F295  | 2118 | 17374987 |   10473 |     |     |          |     |     |         |
| F340  | 1105 | 76859329 |   70742 |     |     |          |     |     |         |
| F354  | 2553 | 23543840 |   11667 |     |     |          |     |     |         |
| F357  | 1541 | 53821193 |   40017 |     |     |          |     |     |         |
| F1084 | 1721 |  4412080 |    3059 |     |     |          |     |     |         |

