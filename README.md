# Processing NCBI sra/EBI ena data

## De novo rna-seq projects

### medfood: medicine food homology. Rna-seq survey.

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
SRX305204,Crataegus_pinnatifida,山楂
SRX800799,Portulaca_oleracea,马齿苋
ERX651070,Glycyrrhiza_glabra,光果甘草

SRX852542,Dolichos_lablab,扁豆
SRX479329,Dimocarpus_longan,龙眼

SRX365197,Cassia_obtusifolia,决明
SRX467333,Prunus_armeniaca,杏
SRX131618,Hippophae_rhamnoides,沙棘
SRX064894,Siraitia_grosvenorii,罗汉果
SRX096106,Lonicera_japonica,忍冬

SRX287501,Houttuynia_cordata,蕺菜
SRX392897,Zingiber_officinale,姜
SRX360220,Gardenia_jasminoides,栀子
SRX246913,Poria_cocos,茯苓
SRX320098,Morus_alba,桑

SRX977888,Citrus_reticulata,橘
SRX314622,Chrysanthemum_morifolium,菊
SRX255211,Cichorium_intybus,菊苣
SRX814013,Brassica_juncea,芥
DRX026628,Perilla_frutescens,紫苏

DRX014826,Pueraria_lobata,野葛
SRX890122,Piper_nigrum,胡椒
SRX533468,Mentha_arvensis,薄荷
SRX848973,Pogostemon_cablin,广藿香
SRX803910,Coriandrum_sativum,芫荽

SRX173215,Rose_rugosa,玫瑰
SRX096128,Prunella_vulgaris,夏枯草
SRX447081,Crocus_sativus,藏红花
SRX146981,Curcuma_Longa,姜黄

SRX761199,Malus_hupehensis,湖北海棠
SRX1023176,Osmanthus_fragrans_Semperflorens,四季桂
SRX1023177,Osmanthus_fragrans_Thunbergii,金桂
SRX1023178,Osmanthus_fragrans_Latifolius,银桂

SRX477950,Oryza_sativa_Japonica,粳稻
SRX1418190,Arabidopsis_thaliana,拟南芥
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="medfood.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl medfood.yml --md5

mkdir -p ~/data/rna-seq/medfood/sra
cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.ftp.txt .
aria2c -x 9 -s 3 -c -i medfood.ftp.txt

cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.md5.txt .
md5sum --check medfood.md5.txt
```

Metainfo of Pueraria_lobata in NCBI is wrong.

```bash
cd ~/Scripts/sra
cat medfood.csv \
    | grep -v "Pueraria_lobata" \
    > medfood_all.csv
echo Pueraria_lobata,DRX014826,ILLUMINA,SINGLE,,DRR016460,23802502,2.19G \
    >> medfood_all.csv
```

Generate bash files and run a sample.

```bash
cd ~/data/rna-seq/medfood
perl ~/Scripts/sra/medfood_seq.pl

bash bash/sra.Cichorium_intybus.sh

```

Open `~/data/rna-seq/medfood/screen.sh.txt` and paste bash lines to terminal.

When the size of `screen.sra_XXX-0.log` reach 6.5K, the process should be finished.
The size of `screen.tri_XXX-0.log` varies a lot, from 700K to 30M.

```bash
cd ~/data/rna-seq/medfood/log

# sra
screen -L -dmS sra_Cichorium_intybus bash /home/wangq/data/rna-seq/medfood/bash/sra.Cichorium_intybus.sh

# screen.sra_Hippophae_rhamnoides-0.log

# ...

# trinity
screen -L -dmS tri_Cichorium_intybus bash /home/wangq/data/rna-seq/medfood/bash/tri.Cichorium_intybus.sh

# ...
```

### chickpea: de novo rna-seq.

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
SRX402846,ShootCold,
SRX402839,RootControl,
SRX402841,RootSalinity,
SRX402842,RootCold,
SRX402843,ShootControl,
SRX402840,RootDesiccation,
SRX402844,ShootDesiccation,
SRX402845,ShootSalinity,
SRX402846,ShootCold,
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="chickpea_rnaseq.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl chickpea_rnaseq.yml --md5

mkdir -p ~/data/rna-seq/chickpea/sra
cd ~/data/rna-seq/chickpea/sra
cp ~/Scripts/sra/chickpea_rnaseq.ftp.txt .
aria2c -x 9 -s 3 -c -i chickpea_rnaseq.ftp.txt

cd ~/data/rna-seq/chickpea/sra
cp ~/Scripts/sra/chickpea_rnaseq.md5.txt .
md5sum --check chickpea_rnaseq.md5.txt
```

## Reference based rna-seq projects

### Human bodymap2

* http://www.ebi.ac.uk/ena/data/view/ERP000546
* http://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP000546

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
ERS025081,kidney,
ERS025082,heart,
ERS025083,ovary,
ERS025085,brain,
ERS025086,lymph_node,
ERS025088,breast,
ERS025089,colon,
ERS025090,thyroid,
ERS025091,white_blood_cells,
ERS025092,adrenal,
ERS025094,testes,
ERS025095,prostate,
ERS025096,liver,
ERS025097,skeletal_muscle,
ERS025098,adipose,
ERS025099,lung,
ERS025084,16_tissues_mixture_1,
ERS025087,16_tissues_mixture_2,
ERS025093,16_tissues_mixture_3,
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="bodymap2.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl bodymap2.yml --md5

mkdir -p ~/data/rna-seq/bodymap2/sra
cd ~/data/rna-seq/bodymap2/sra
cp ~/Scripts/sra/bodymap2.ftp.txt .
aria2c -x 9 -s 3 -c -i bodymap2.ftp.txt

cd ~/data/rna-seq/bodymap2/sra
cp ~/Scripts/sra/bodymap2.md5.txt .
md5sum --check bodymap2.md5.txt
```

### Mouse transcriptome

http://www.ebi.ac.uk/ena/data/view/SRP012040

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
SRX135150,Ovary,
SRX135151,MammaryGland,
SRX135152,Stomach,
SRX135153,SmIntestine,
SRX135154,Duodenum,
SRX135155,Adrenal,
SRX135156,LgIntestine,
SRX135157,GenitalFatPad,
SRX135158,SubcFatPad,
SRX135159,Thymus,
SRX135160,Testis,
SRX135161,Kidney,
SRX135162,Liver,
SRX135163,Lung,
SRX135164,Spleen,
SRX135165,Colon,
SRX135166,Heart,
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="mouse_transcriptome.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl mouse_transcriptome.yml --md5

mkdir -p ~/data/rna-seq/mouse_trans/sra
cd ~/data/rna-seq/mouse_trans/sra
cp ~/Scripts/sra/mouse_transcriptome.ftp.txt .
aria2c -x 9 -s 3 -c -i mouse_transcriptome.ftp.txt

cd ~/data/rna-seq/mouse_trans/sra
cp ~/Scripts/sra/mouse_transcriptome.md5.txt .
md5sum --check mouse_transcriptome.md5.txt
```

### Rat hypertension

Information.

```bash
cat <<EOF > ~/Scripts/sra/rat_hypertension.csv
name,srx,platform,layout,ilength,srr,spot,base
Control,Control_S4,Illumina,PAIRED,,Control_S4,,
QHDG,QHDG_S12,Illumina,PAIRED,,QHDG_S12,,
QLDG,QLDG_S13,Illumina,PAIRED,,QLDG_S13,,
EOF

```

Prepare reference genome.

```bash
mkdir -p ~/data/alignment/Ensembl/Rat
cd ~/data/alignment/Ensembl/Rat

#curl -O --socks5 127.0.0.1:1080 ftp://ftp.ensembl.org/pub/release-82/fasta/rattus_norvegicus/dna/Rattus_norvegicus.Rnor_6.0.dna_sm.toplevel.fa.gz
wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/rattus_norvegicus/dna/Rattus_norvegicus.Rnor_6.0.dna_sm.toplevel.fa.gz

gzip -d -c Rattus_norvegicus.Rnor_6.0.dna_sm.toplevel.fa.gz > toplevel.fa
faops count toplevel.fa | perl -aln -e 'next if $F[0] eq 'total'; print $F[0] if $F[1] > 50000; print $F[0] if $F[1] > 5000  and $F[6]/$F[1] < 0.05' | uniq > listFile
faops some toplevel.fa listFile toplevel.filtered.fa
faops split-name toplevel.filtered.fa .
rm toplevel.fa toplevel.filtered.fa listFile

cat KL*.fa > Un.fa
cat AABR*.fa >> Un.fa
rm KL*.fa AABR*.fa

mkdir -p ~/data/rna-seq/rat_hypertension/ref
cd ~/data/rna-seq/rat_hypertension/ref

cat ~/data/alignment/Ensembl/Rat/{1,2,3,4,5,6,7,8,9,10}.fa > rat_82.fa
cat ~/data/alignment/Ensembl/Rat/{11,12,13,14,15,16,17,18,19,20}.fa >> rat_82.fa
cat ~/data/alignment/Ensembl/Rat/{X,Y,MT,Un}.fa >> rat_82.fa
faops size rat_82.fa > chr.sizes

samtools faidx rat_82.fa
bwa index -a bwtsw rat_82.fa
bowtie2-build rat_82.fa rat_82

java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=rat_82.fa O=rat_82.dict

wget -N ftp://ftp.ensembl.org/pub/release-82/gtf/rattus_norvegicus/Rattus_norvegicus.Rnor_6.0.82.gtf.gz
gzip -d -c Rattus_norvegicus.Rnor_6.0.82.gtf.gz > rat_82.gtf

perl -nl -e '/^(MT|KL|AABR)/ and print' rat_82.gtf > rat_82.mask.gtf

```

Generate bash files.

```bash
cd ~/data/rna-seq/rat_hypertension
perl ~/Scripts/sra/rat_hypertension_seq.pl

bash bash/sra.Control.sh

```

## Reference based dna-seq projects

### cele_mmp: 40 wild strains from *C. elegans* million mutation project

From http://genome.cshlp.org/content/23/10/1749.abstract ,
http://genome.cshlp.org/content/suppl/2013/08/20/gr.157651.113.DC2/Supplemental_Table_12.txt

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
SRX218993,AB1,
SRX218973,AB3,
SRX218981,CB4853,
SRX218994,CB4854,
SRX219150,CB4856,
SRX218999,ED3017,
SRX219003,ED3021,
SRX218982,ED3040,
SRX219000,ED3042,
SRX218983,ED3049,
SRX218984,ED3052,
SRX219004,ED3057,
SRX218977,ED3072,
SRX218988,GXW1,
SRX218989,JU1088,
SRX218974,JU1171,
SRX218990,JU1400,
SRX218979,JU1401,
SRX218975,JU1652,
SRX218971,JU258,
SRX218978,JU263,
SRX218991,JU300,
SRX218992,JU312,
SRX218969,JU322,
SRX219001,JU345,
SRX219005,JU360,
SRX219002,JU361,
SRX219153,JU394,
SRX218972,JU397,
SRX218980,JU533,
SRX218970,JU642,
SRX219006,JU775,
SRX218995,KR314,
SRX218996,LKC34,
SRX218997,MY1,
SRX218966,MY14,
SRX218967,MY16,
SRX218998,MY2,
SRX218968,MY6,
SRX219154,PX174,
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="cele_mmp.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra
perl sra_prep.pl -i cele_mmp.yml --md5

mkdir -p ~/data/dna-seq/cele_mmp/sra
cd ~/data/dna-seq/cele_mmp/sra
cp ~/Scripts/sra/cele_mmp.ftp.txt .
aria2c -x 9 -s 3 -c -i cele_mmp.ftp.txt

cd ~/data/dna-seq/cele_mmp/sra
cp ~/Scripts/sra/cele_mmp.md5.txt .
md5sum --check cele_mmp.md5.txt

# rsync -avP wangq@45.79.80.100:data/dna-seq/ ~/data/dna-seq
```

Prepare reference genome.

`~/data/alignment/Ensembl/Cele` should contain [C. elegans genome files](https://github.com/wang-q/withncbi/blob/master/pop/OPs-download.md#caenorhabditis-elegans) from ensembl.

```bash
mkdir -p ~/data/dna-seq/cele_mmp/ref
cd ~/data/dna-seq/cele_mmp/ref

cat ~/data/alignment/Ensembl/Cele/{I,II,III,IV,V,X}.fa > Cele_82.fa
faops size Cele_82.fa > chr.sizes

samtools faidx Cele_82.fa
bwa index -a bwtsw Cele_82.fa

java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=Cele_82.fa O=Cele_82.dict
```

Generate bash files and run a sample.

```bash
cd ~/data/dna-seq/cele_mmp
perl ~/Scripts/sra/cele_mmp_seq.pl

bash bash/sra.AB1.sh

```

Open `~/data/dna-seq/cele_mmp/screen.sh.txt` and paste bash lines to terminal.

### dicty

SRA012238, SRP002085

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
SRX017832,QS1,
SRX017812,68,
SRX018144,QS17,
SRX018099,WS15,
SRX018021,WS14,
SRX018020,S224,
SRX018019,QS9,
SRX018018,QS80,
SRX018017,QS74,
SRX018016,QS73,
SRX018015,QS69,
SRX018012,QS4,
SRX018011,QS37,
SRX017848,QS36,
SRX017847,QS23,
SRX017846,QS18,
SRX017845,QS11,
SRX017814,AX4,
SRX017813,70,
SRX017442,TW5A,
SRX017441,TW5A,
SRX017440,MA12C1,
SRX017439,MA12C1,
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="dicty.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl dicty.yml --md5

mkdir -p ~/data/dna-seq/dicty/sra
cd ~/data/dna-seq/dicty/sra
cp ~/Scripts/sra/dicty.ftp.txt .
aria2c -x 9 -s 3 -c -i dicty.ftp.txt

cd ~/data/dna-seq/dicty/sra
cp ~/Scripts/sra/dicty.md5.txt .
md5sum --check dicty.md5.txt
```

### ath19

ERP000565 ERA023479

sf-2 is missing, use downloaded bam file.

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
ERS025622,Bur_0,
ERS025623,Can_0,
ERS025624,Col_0,
ERS025625,Ct_1,
ERS025626,Edi_0,
ERS025627,Hi_0,
ERS025628,Kn_0,
ERS025629,Ler_0,
ERS025630,Mt_0,
ERS025631,No_0,
ERS025632,Oy_0,
ERS025633,Po_0,
ERS025634,Rsch_4,
ERS025635,Sf_2,
ERS025636,Tsu_0,
ERS025637,Wil_2,
ERS025638,Ws_0,
ERS025639,Wu_0,
ERS025640,Zu_0,
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="ath19.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl ath19.yml --md5

mkdir -p ~/data/dna-seq/ath19/sra
cd ~/data/dna-seq/ath19/sra
cp ~/Scripts/sra/ath19.ftp.txt .
aria2c -x 9 -s 3 -c -i ath19.ftp.txt

cd ~/data/dna-seq/ath19/sra
cp ~/Scripts/sra/ath19.md5.txt .
md5sum --check ath19.md5.txt
```

### japonica24

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
#TEJ
SRS086330,IRGC1107,
SRS086334,IRGC2540,
SRS086337,IRGC27630,
SRS086341,IRGC32399,
SRS086345,IRGC418,
SRS086354,IRGC55471,
SRS086360,IRGC8191,
# tagged as TRJ in Table.S1
SRS086343,IRGC38698,

#TRJ
SRS086329,IRGC11010,
SRS086333,IRGC17757,
SRS086342,IRGC328,
SRS086346,IRGC43325,
SRS086349,IRGC43675,
SRS086351,IRGC50448,
SRS086358,IRGC66756,
SRS086362,IRGC8244,
SRS086336,IRGC26872,

#ARO
SRS086331,IRGC12793,
SRS086344,IRGC38994,
SRS086365,IRGC9060,
SRS086366,IRGC9062,
SRS086371,RA4952,
SRS086340,IRGC31856,

# IRGC43397 is admixed
# So there are 23 japonica accessions
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="japonica24.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = exists $master->{$name} 
            ? $master->{$name}
            : {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl japonica24.yml --md5

mkdir -p ~/data/dna-seq/japonica24/sra
cd ~/data/dna-seq/japonica24/sra
cp ~/Scripts/sra/japonica24.ftp.txt .
aria2c -x 9 -s 3 -c -i japonica24.ftp.txt

cd ~/data/dna-seq/japonica24/sra
cp ~/Scripts/sra/japonica24.md5.txt .
md5sum --check japonica24.md5.txt
```

## Unused projects

* Glycine max Genome sequencing: SRP015830, PRJNA175477
* 10_000_diploid_yeast_genomes: ERP000547, PRJEB2446
* Arabidopsis thaliana recombinant tetrads and DH lines: ERP003793, PRJEB4500
* Resequencing of 50 rice individuals: SRP003189
* rice_omachi: DRX000450
