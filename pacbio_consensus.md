# PacBio consensus


[TOC levels=1-3]: #

# Table of Contents
- [PacBio consensus](#pacbio-consensus)
- [RS II 与 Sequel 对比](#rs-ii-与-sequel-对比)
- [文档](#文档)
    - [[几个术语](http://www.pacb.com/wp-content/uploads/2015/09/Pacific-Biosciences-Glossary-of-Terms.pdf)](#几个术语)
    - [[Falcon 参数](https://github.com/PacificBiosciences/FALCON/wiki/Manual)](#falcon-参数)
    - [Falcon 结果文件](#falcon-结果文件)
- [分析平台的历史](#分析平台的历史)
- [使用 pitchfork 安装 GenomicConsensus 和 falcon](#使用-pitchfork-安装-genomicconsensus-和-falcon)
    - [安装Linuxbrew](#安装linuxbrew)
    - [安装最新的第三方依赖.](#安装最新的第三方依赖)
    - [通过 pitchfork 编译.](#通过-pitchfork-编译)
    - [直接安装 falcon-integrate, 现在不推荐](#直接安装-falcon-integrate-现在不推荐)
- [falcon 样例数据](#falcon-样例数据)
    - [`falcon/example` 里的 [*E. coli* 样例](https://github.com/PacificBiosciences/FALCON/wiki/Setup:-Complete-example).](#falconexample-里的-e-coli-样例)
    - [E. coli Bacterial Assembly (P6C4)](#e-coli-bacterial-assembly-p6c4)
    - [C. elegans](#c-elegans)
    - [复活草](#复活草)
    - [Atha Ler-0](#atha-ler-0)
    - [Scer S288c](#scer-s288c)
    - [其它模式生物](#其它模式生物)
- [其它相关的程序](#其它相关的程序)
    - [PacBio 自产](#pacbio-自产)
    - [混合组装](#混合组装)
- [中文资料](#中文资料)

# RS II 与 Sequel 对比

现在主流的两种 PacBio 平台
[RS II 与 Sequel 对比](http://allseq.com/knowledge-bank/sequencing-platforms/pacific-biosciences/)

P 指得是聚合酶, C 是化学试剂.

|                          | RS II (P6-C4) |  Sequel  |
|:-------------------------|:-------------:|:--------:|
| Run time                 |    240 min    | 240 min  |
| Total output             |   0.5-1 Gb    | 5-10 Gb  |
| Output/day               |     2 Gb      |  20 Gb   |
| Mean read length         |   10-15 kb    | 10-15 kb |
| Single pass accuracy     |     ~86%      |   ~86%   |
| Consensus (30X) accuracy |   >99.999%    | >99.999% |
| # of reads               |      50k      |   500k   |
| Instrument price         |     $700k     |  $350k   |
| Run price                |     $400      |   $850   |

|                    |  Sequel   |                  原因                   |
|:-------------------|:---------:|:--------------------------------------:|
| Human Whole Genome |  Ok/Good  | 贵; 低偏向, 长读长, 利于鉴定结构变异及组装  |
| Small Genome       |   Good    |         长读长, 只需要较低的通量          |
| Targeted           |   Good    |         长读长, 只需要较低的通量          |
| Transcriptome      | Poor/Good |       贵; 但二代没法得到全长的转录本       |
| Metagenomics       |  Poor/Ok  |         贵; 但利于 de novo 组装          |
| Exome              |   Poor    |        贵; 长读长对外显子没有用处         |
| RNA Profiling      |   Poor    |                   贵                   |
| ChIP-Seq           |   Poor    |                   贵                   |

# 文档

* PacBio 在 github 上的[首页](https://github.com/PacificBiosciences)
* [Quiver HowTo](https://github.com/PacificBiosciences/GenomicConsensus/blob/master/doc/HowTo.rst)
* [Quiver FAQ](https://github.com/PacificBiosciences/GenomicConsensus/blob/master/doc/FAQ.rst)
* [FALCON Manual](https://github.com/PacificBiosciences/FALCON/wiki/Manual)
* [FALCON Tips](https://github.com/PacificBiosciences/FALCON/wiki/Tips)
* [PacBio 的 slides](https://speakerdeck.com/pacbio)
* [一些基本定义, p24-28](https://speakerdeck.com/pacbio/specifics-of-smrt-sequencing-data)
* HDF5 即将成为历史, PacBio 正在向 BAM 转移
* [PacBio 的 BAM 格式](http://pacbiofileformats.readthedocs.io/en/3.0/BAM.html)
* [UC DAVIS](http://dnatech.genomecenter.ucdavis.edu/2016/11/10/new-service-long-read-sequencing-on-the-pacbio-sequel/)
* Falcon 问题合集
    * [Trace assembled and unassembled reads in FALCON](https://github.com/PacificBiosciences/FALCON/issues/472)
    * [Is there any need to polish the assembly result with quiver?](https://github.com/PacificBiosciences/FALCON/issues/304)
    * [minimum sequencing depth requirement for FALCON](https://github.com/PacificBiosciences/FALCON/issues/256)
    * [Hybrid Assembly using falcon](https://github.com/PacificBiosciences/FALCON/issues/282)
    * 调整 falcon 参数
        * [Falcon assembly](https://github.com/PacificBiosciences/FALCON/issues/308)
        * [how to set the appropriate config file for larger genome using local mode](https://github.com/PacificBiosciences/FALCON/issues/466)

## [几个术语](http://www.pacb.com/wp-content/uploads/2015/09/Pacific-Biosciences-Glossary-of-Terms.pdf)

* Subreads - 测序仪直接输出的实时序列, SMRTbell 两个接头之间的序列.
* CCS - 对于较短的模板, 聚合酶在会在环形的 SMRTbell 上环绕多次, 即对同一序列测序多次. 得到的保守序列即为 CCS.
* Long reads - 模板较长, 聚合酶没有抵达 SMRTbell 另一端的接头.
* `.subreads.bam` - 可直接用于分析的 subreads.
* `.scraps.bam` - 接头, 标签和可能有问题的 subreads.

## [Falcon 参数](https://github.com/PacificBiosciences/FALCON/wiki/Manual)

* input_fofn - 输入的 fasta 文件路径
* input_type - `raw` for subreads, `preads` for error corrected reads
* length_cutoff - 用于纠错步骤的种子 reads 长度, 可设得稍小一点, 以达到 15x - 20x 覆盖量
* length_cutoff_pr - 用于组装的 reads 长度. 这一步里 reads 多并不代表好, 可以多调整
* pa_concurrent_jobs
* falcon_sense_option - 用于 fc_consensus.py
    * --min_cov - controls when a seed read gets trimmed or broken due to low coverage
    * --max_n_read - puts a cap on the number of reads used for error correction. 对于高重复的基因组,
      这个得设得小一点.
* pa_* - 纠错步骤的参数
* ovlp_* - 组装步骤的参数
* overlap_filtering_setting - 简化 overlap graph 里的 edges.
    * --bestn - "best n overlaps" in the 5' or 3' ends
    * --max_cov, --min_cov, --max_diff - 简单的 reads 两端的 coverages 应该是平衡的, 如果其中包含了
      repeats, 则两端会出现不平衡的状态, 即含有 repeats 的一端 coverages 会高很多. 如果一个 reads 的错误比例太高,
      也可以通过这种方法把它排除出去.
    * What is the right numbers used for these parameters? These parameters may the most tricky ones
      to be set right. If the overall coverage of the error corrected reads longer than the length
      cut off is known and reasonable high (e.g. greater than 20x), it might be safe to set min_cov
      to be 5, max_cov to be three times of the average coverage and the max_diff to be twice of the
      average coverage. However, in low coverage case, it might better to set min_cov to be one or
      two. A helper script called fc_ovlp_stats.py can help to dump the number of the 3' and 5'
      overlap of a given length cutoff, you can plot the distribution of the number of overlaps to
      make a better decision.

##  Falcon 结果文件

* `daligner`
    * `0-rawreads/job_*`
    * 每进程两线程
* `fc_consensus`
    * `0-rawreads/m_*`
    * 由 `falcon_sense_option` 里的 `--n_core` 指定线程数. 内部会竞争 CPU, 超出 CPU 数量会极大地降低性能
* `FA4Falcon`
    * `0-rawreads/preads/cns_*`
    * 前面合并的 rawreads 生成 preads, 高 I/O. 耗时最长.

* `0-rawreads/`
    * `0-rawreads/preads/` - the error corrected reads
* `1-preads_ovl/` - pread overlaps
* `2-asm-falcon/`
    * `p_ctg.fa` - primary contigs, 组装好的 draft genome
    * `a_ctg.fa` - alternative contigs, 无法区分的 contigs, 可能是二倍体, 也可能是重复序列
    * `sg_edges_list` - 原始 reads 之间的联系, 也就是组装 string graph 里的 edges. 可以用它将 reads 映射回
      contigs

# 分析平台的历史

GenomicConsensus 是 PacBio 的组合程序包 SMRT Analysis Software (SMRTanalysis) 的一部分. 用于 consensus 和
variant calling. SMRTanalysis 的当前版本为 v2.3.0, 发表时间为2014年. v3.0 好像已经跳票, v3.2
不知道什么时候出来.

SMRTanalysis 包括了一些第三方程序:

* 编程语言
    * Java 7
    * Mono 3
    * Perl 5.8
    * Python 2.7
    * Scala 2.9
* 平台
    * Tomcat 7.0.23
    * MySQL 5.1.73
    * Docutils
* 生物信息学工具
    * Celera Assembler 8.1
    * GMAP
    * HMMER 3.1
    * SAMtools

在版本更替过程中, 出现过多个程序, 有些已经死了, 有的正在死.

* Quiver - 基于条件随机场 (conditional random field, CRF), 计算拟极大似然值 (maximum quasi-likelihood),
  以降低 consensus 的错误率, 最近版本中已经被放弃, 只用于 PacBio RS.
* Arrow - 基于隐马模型 (HMM), 适用于 PacBio Sequel and RS.
* Plurality - 用于variant calling, 忽略.
* EviCons - v1.3.1 中移除.

[GenomicConsensus](https://github.com/PacificBiosciences/GenomicConsensus) 背后的库叫
[ConsensusCore](https://github.com/PacificBiosciences/ConsensusCore), 这是安装 Quiver 所需要的.

但是, ConsensusCore 也死了, 后继者叫做
[ConsensusCore2](https://github.com/PacificBiosciences/ConsensusCore2), 这个后继者也未能幸免.

ConsensusCore2 的后继者叫 [unanimity](https://github.com/PacificBiosciences/unanimity). 这个家伙已经与
Quiver 没关系了. 因此, 我们不能直接从最新的代码中得到可以运行的 Quiver.

PacBio 也知道它的程序是一团乱麻, 给了一个从源码安装的方法,
[pitchfork](https://github.com/PacificBiosciences/pitchfork), 还很酷地表示, 这是 unsupported.

# 使用 pitchfork 安装 GenomicConsensus 和 falcon

## 安装Linuxbrew

```bash
echo "==> Install dependencies"
sudo apt-get install build-essential curl git python-setuptools ruby

echo "==> Clone latest linuxbrew"
git clone https://github.com/Linuxbrew/brew.git ~/.linuxbrew

# .bashrc
if grep -q -i linuxbrew $HOME/.bashrc; then
    echo "==> .bashrc already contains linuxbrew"
else
    echo "==> Update .bashrc"

    LB_PATH='export PATH="$HOME/.linuxbrew/bin:$PATH"'
    LB_MAN='export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"'
    LB_INFO='export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"'
    echo '# Linuxbrew' >> $HOME/.bashrc
    echo $LB_PATH >> $HOME/.bashrc
    echo $LB_MAN  >> $HOME/.bashrc
    echo $LB_INFO >> $HOME/.bashrc
    echo >> $HOME/.bashrc

    eval $LB_PATH
    eval $LB_MAN
    eval $LB_INFO
fi
```

## 安装最新的第三方依赖.

```bash
brew install md5sha1sum
brew install zlib boost openblas
brew install python cmake ccache hdf5
brew install samtools
brew cleanup # only keep the latest version

pip install --upgrade pip setuptools wheel
pip install --upgrade virtualenv
```

其它可能有用的程序.

```bash
echo "==> Add tap science"
brew tap homebrew/science
brew tap wang-q/tap

echo "==> Install bioinfomatics softwares"
brew install clustal-w mafft    # aligning
brew install seqtk              # fa/fq transforming
brew install quast              # assembly statistics

echo "==> Install wang-q/tap"
brew install faops
```

## 通过 pitchfork 编译.

```bash
mkdir -p ~/share
cd ~/share
git clone https://github.com/PacificBiosciences/pitchfork
cd ~/share/pitchfork

cat <<EOF > settings.mk
HAVE_ZLIB     = $(brew --prefix)/Cellar/$(brew list --versions zlib | sed 's/ /\//')
HAVE_BOOST    = $(brew --prefix)/Cellar/$(brew list --versions boost | sed 's/ /\//')
HAVE_OPENBLAS = $(brew --prefix)/Cellar/$(brew list --versions openblas | sed 's/ /\//')

HAVE_PYTHON   = $(brew --prefix)/bin/python
HAVE_CMAKE    = $(brew --prefix)/bin/cmake
HAVE_CCACHE   = $(brew --prefix)/Cellar/$(brew list --versions ccache | sed 's/ /\//')/bin/ccache
HAVE_HDF5     = $(brew --prefix)/Cellar/$(brew list --versions hdf5 | sed 's/ /\//')

EOF

# fix bugs in several Makefile
sed -i".bak" "/rsync/d" ~/share/pitchfork/ports/python/virtualenv/Makefile

sed -i".bak" "s/-- third-party\/cpp-optparse/--remote/" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile
sed -i".bak" "/third-party\/gtest/d" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile
sed -i".bak" "/ccache /d" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile

cd ~/share/pitchfork
make pip
deployment/bin/pip install --upgrade pip setuptools wheel virtualenv

make GenomicConsensus
make pbfalcon
make pbreports
```

编译好的可执行文件与库文件在 `~/share/pitchfork/deployment`.

试运行.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

quiver --help
```

单独安装 dextractor, 稍稍修改了下. Falcon 自带的版本只编译了 `dexta` 和 `undexta`.

```bash
cd ~/share
git clone https://github.com/wang-q/DEXTRACTOR
cd ~/share/DEXTRACTOR

cat <<EOF > settings.mk
HAVE_ZLIB = $(brew --prefix)/Cellar/$(brew list --versions zlib | sed 's/ /\//')
HAVE_HDF5 = $(brew --prefix)/Cellar/$(brew list --versions hdf5 | sed 's/ /\//')

EOF

make

```

## 直接安装 falcon-integrate, 现在不推荐

[wiki page](https://github.com/PacificBiosciences/FALCON-integrate/wiki/Installation)

```bash
mkdir -p $HOME/share
cd $HOME/share

git clone git://github.com/PacificBiosciences/FALCON-integrate.git
cd FALCON-integrate
git checkout master  # or whatever version you want
make init
source env.sh
make config-edit-user
make -j all

# Test data stored in dropbox. f* gfw
# make test
```

编译完成后, 会生成`fc_env`目录, 里面是可执行文件. `tree -L 2 fc_env`, `6 directories, 79 files`.

# falcon 样例数据

falcon-examples里的数据是通过一个小众程序`git-sym`从dropbox下载的, 在墙内无法按说明文件里的提示来使用.

同时其内的很多设置都是写死的集群路径, 以及sge配置, 大大增加了复杂度, 并让人无法理解.

注意:

* fasta 文件**必须**以 `.fasta` 为扩展名
* fasta 文件中的序列名称, 必须符合 falcon (fasta2DB of dazz_db) 的要求, 即 sra 默认名称**不符合要求**,
  错误提示为 `Pacbio header line format error`
* [这里](https://github.com/PacificBiosciences/FALCON/issues/251)有个脚本帮助解决这个问题. 已经放到本地,
  `falcon_name_fasta.pl`

* Clear intermediate dirs

    ```bash
    find $HOME/data/pacbio -type d -name 'm_*' | xargs rm -fr
    find $HOME/data/pacbio -type d -name 'job_*' | xargs rm -fr
    ```

## `falcon/example` 里的 [*E. coli* 样例](https://github.com/PacificBiosciences/FALCON/wiki/Setup:-Complete-example).

* 过墙下载以下三个文件

```bash
mkdir -p $HOME/data/pacbio/rawdata/ecoli_test
cd $HOME/data/pacbio/rawdata/ecoli_test

proxychains4 wget -c https://www.dropbox.com/s/tb78i5i3nrvm6rg/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.1.subreads.fasta
proxychains4 wget -c https://www.dropbox.com/s/v6wwpn40gedj470/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.2.subreads.fasta
proxychains4 wget -c https://www.dropbox.com/s/j61j2cvdxn4dx4g/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.3.subreads.fasta

# N50 14124
# C   105451
faops n50 -C *.subreads.fasta
```

* 配置文件及运行

```bash
source ~/share/pitchfork/deployment/setup-env.sh

if [ -d $HOME/data/pacbio/ecoli_test ];
then
    rm -fr $HOME/data/pacbio/ecoli_test
fi
mkdir -p $HOME/data/pacbio/ecoli_test
cd $HOME/data/pacbio/ecoli_test
find $HOME/data/pacbio/rawdata/ecoli_test -name "*.fasta" > input.fofn

# https://github.com/PacificBiosciences/FALCON/blob/master/examples/fc_run_ecoli.cfg
cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 4
ovlp_concurrent_jobs = 4

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 2

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 2

EOF

# macOS, i7-6700k, 32G RAM, SSD
# Unfinished

# Ubuntu 14.04, E5-2690 v3 x 2, 128G RAM, HDD
#real    116m27.337s
#user    940m48.526s
#sys     194m47.010s
time fc_run fc_run.cfg
```

## E. coli Bacterial Assembly (P6C4)

https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly

下载 7 GB 的 E. coli (20 kb library) 数据, 它是 RS II 上 P6C4 的运行结果.

先转化为 `.subreads.bam`, 再转化为 `fasta`.

```bash
mkdir -p ~/data/pacbio/rawdata/ecoli_p6c4
cd ~/data/pacbio/rawdata/ecoli_p6c4
curl -O https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-P6C4/p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

source ~/share/pitchfork/deployment/setup-env.sh

tar xvfz p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

mkdir -p ~/data/pacbio/rawdata/ecoli_p6c4/bam
cd ~/data/pacbio/rawdata/ecoli_p6c4/bam

bax2bam ~/data/pacbio/rawdata/ecoli_p6c4/E01_1/Analysis_Results/*.bax.h5

xmllint --format ~/data/pacbio/rawdata/ecoli_p6c4/E01_1/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.metadata.xml \
    > m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.metadata.xml

mkdir -p ~/data/pacbio/rawdata/ecoli_p6c4/fasta
cd ~/data/pacbio/rawdata/ecoli_p6c4/fasta

bamtools convert -format fasta \
    -in ~/data/pacbio/rawdata/ecoli_p6c4/bam/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.subreads.bam \
    -out m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.subreads.fasta

# N50 13982; 87225
faops n50 -C *.subreads.fasta
```

运行 falcon.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

if [ -d $HOME/data/pacbio/ecoli_p6c4 ];
then
    rm -fr $HOME/data/pacbio/ecoli_p6c4
fi
mkdir -p $HOME/data/pacbio/ecoli_p6c4
cd $HOME/data/pacbio/ecoli_p6c4
find $HOME/data/pacbio/rawdata/ecoli_p6c4/fasta -name "*.fasta" > input.fofn

cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 4
ovlp_concurrent_jobs = 4

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 2

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 2

EOF

#real    104m51.013s
#user    450m44.099s
#sys     501m49.603s
time fc_run fc_run.cfg

#N50     4641042
#C       1
faops n50 -C 2-asm-falcon/p_ctg.fa
```

## E. coli canu

```bash
mkdir -p ~/data/pacbio/rawdata/ecoli_canu
cd ~/data/pacbio/rawdata/ecoli_canu

curl -L -o p6.25x.fastq http://gembox.cbcb.umd.edu/mhap/raw/ecoli_p6_25x.filtered.fastq

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install canu
brew install gnuplot
brew unlink gnuplot
brew install gnuplot4
brew unlink gnuplot4
brew link gnuplot4
```

```bash
canu \
    -p ecoli -d ecoli-auto \
    gnuplot=$HOME/.linuxbrew/Cellar/gnuplot/5.0.5_2/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw p6.25x.fastq
```

## C. elegans

https://github.com/PacificBiosciences/DevNet/wiki/C.-elegans-data-set

```bash
mkdir -p ~/data/pacbio/rawdata/c_elegans_p6c4
cd ~/data/pacbio/rawdata/c_elegans_p6c4

proxychains4 perl ~/Scripts/download/list.pl -u http://datasets.pacb.com.s3.amazonaws.com/2014/c_elegans/wget.html --ncp

cat 2014_c_elegans_wget.html.yml \
    | grep subreads.fasta \
    | perl -nl -e '($url, undef) = split q{: }; $url =~ s/^\s+//g; print $url;' \
    > s3.url.txt

# on linode VPS
aria2c -x 9 -s 3 -c -i s3.url.txt

#sudo apt-get install pigz
find . -type f -name "*.fasta" | xargs pigz

# local
rsync -avP wangq@45.79.80.100:data/pacbio/rawdata/ ~/data/pacbio/rawdata

#N50     55460
#S       8117663505
#C       740776
faops n50 -S -C *.subreads.fasta.gz
```

## 复活草

* 预处理

```text
$ ls -al ~/zlc/Oropetium_thomaeum/pacbio/data/
total 2517104
drwxrwxr-x 2 wangq wangq       4096 Nov  2 15:03 .
drwxrwxr-x 4 wangq wangq       4096 Nov  2 15:04 ..
-rw-rw-r-- 1 wangq wangq 2577500677 Nov  2 15:36 head80.fa

$ head -n 1 ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fa
>SRR2058409.1 1 length=5249

$ perl ~/Scripts/sra/falcon_name_fasta.pl -i data/head80.fa

$ head -n 1 ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fa.outfile
>falcon_read/000001/0_5249

$ mv ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fa.outfile ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fasta
```

* 配置文件及运行

```bash
cd $HOME/share/FALCON-integrate
source env.sh

if [ -d ~/zlc/Oropetium_thomaeum/pacbio/falcon ];
then
    rm -fr ~/zlc/Oropetium_thomaeum/pacbio/falcon
fi
mkdir -p ~/zlc/Oropetium_thomaeum/pacbio/falcon
cd ~/zlc/Oropetium_thomaeum/pacbio/falcon
find ~/zlc/Oropetium_thomaeum/pacbio/data/ -name "*.fasta" > input.fofn

cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 16
ovlp_concurrent_jobs = 16

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 6

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 24

EOF

fc_run fc_run.cfg
```

## Atha Ler-0

* 三代原始数据

```bash
cd ~/data/pacbio/rawdata/
perl ~/Scripts/download/list.pl -u https://downloads.pacbcloud.com/public/SequelData/ArabidopsisDemoData/
perl ~/Scripts/download/download.pl -a -i public_SequelData_ArabidopsisDemoData.yml

aria2c -x 9 -s 3 -c -i /home/wangq/data/pacbio/rawdata/public_SequelData_ArabidopsisDemoData.yml.txt
```

* 二代数据

之前在 ERA 下载的数据, 方法在[这里](README.md#ath19). 这里用的是 GA IIx, 长度只有 50 bp, 放弃.
用[这个](README.md#atha-ler-0).

用 `superreads.pl` 运行 masurca

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR616965
cd ~/data/dna-seq/atha_ler_0/superreads/SRR616965

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_2.fastq.gz \
    -s 450 -d 50

```

`.subreads.bam` to fasta

```bash
mkdir -p $HOME/data/pacbio/rawdata/ler0_test/fasta
cd $HOME/data/pacbio/rawdata/ler0_test/fasta

# segfault
#dextract ~/data/pacbio/rawdata/public/SequelData/ArabidopsisDemoData/SequenceData/1_A01_customer/m54113_160913_184949.subreads.bam

samtools fasta \
    ~/data/pacbio/rawdata/public/SequelData/ArabidopsisDemoData/SequenceData/1_A01_customer/m54113_160913_184949.subreads.bam \
    > m54113_160913_184949.fasta

samtools fasta \
    ~/data/pacbio/rawdata/public/SequelData/ArabidopsisDemoData/SequenceData/3_C01_customer/m54113_160914_092411.subreads.bam \
    > m54113_160914_092411.fasta

#N50     70763
#S       10753458447
#C       1135065
faops n50 -C -S *.fasta
```

```bash
source ~/share/pitchfork/deployment/setup-env.sh

if [ -d $HOME/data/pacbio/ler0_test ];
then
    rm -fr $HOME/data/pacbio/ler0_test
fi
mkdir -p $HOME/data/pacbio/ler0_test
cd $HOME/data/pacbio/ler0_test
find $HOME/data/pacbio/rawdata/ler0_test/fasta -name "*.fasta" > input.fofn

cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 16
ovlp_concurrent_jobs = 16

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 6

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 24

EOF

fc_run fc_run.cfg
```

## Scer S288c

From [project PRJEB7245](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB7245),
[study ERP006949](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP006949),
and [sample SAMEA4461733](https://www.ncbi.nlm.nih.gov/biosample/5850878).

P6C4.

`.bax.h5` files to `.subreads.bam`, then to `fasta`.

```bash
mkdir -p ~/data/pacbio/rawdata/S288c
cd ~/data/pacbio/rawdata/S288c

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655118_ERR1655118_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655120_ERR1655120_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655122_ERR1655122_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655124_ERR1655124_hdf5.tgz

EOF

aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
source ~/share/pitchfork/deployment/setup-env.sh

mkdir -p ~/data/pacbio/rawdata/S288c/untar
cd ~/data/pacbio/rawdata/S288c
tar xvfz ERR1655118_ERR1655118_hdf5.tgz --directory untar
tar xvfz ERR1655120_ERR1655120_hdf5.tgz --directory untar
tar xvfz ERR1655122_ERR1655122_hdf5.tgz --directory untar
tar xvfz ERR1655124_ERR1655124_hdf5.tgz --directory untar

# bax2bam
mkdir -p ~/data/pacbio/rawdata/S288c/bam
cd ~/data/pacbio/rawdata/S288c/bam

for movie in m150412 m150415 m150417 m150421;
do 
    bax2bam ~/data/pacbio/rawdata/S288c/untar/${movie}*.bax.h5
done

# bam to fasta
mkdir -p ~/data/pacbio/rawdata/S288c/fasta

for movie in m150412 m150415 m150417 m150421;
do 
    samtools fasta \
        ~/data/pacbio/rawdata/S288c/bam/${movie}*.subreads.bam \
        > ~/data/pacbio/rawdata/S288c/fasta/${movie}.fasta
done

#N50     8248
#S       2585714835
#C       600574
faops n50 -S -C ~/data/pacbio/rawdata/S288c/fasta/*.fasta
```

Assembled genomes and annotations.

```bash
cd ~/data/pacbio/rawdata/
perl ~/Scripts/download/list.pl -u https://yjx1217.github.io/Yeast_PacBio_2016/data/
perl ~/Scripts/download/download.pl -a -i Yeast_PacBio_2016_data.yml

proxychains4 aria2c -x 9 -s 3 -c -i ~/data/pacbio/rawdata/Yeast_PacBio_2016_data.yml.txt
```

运行 falcon.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

if [ -d $HOME/data/pacbio/S288c_p6c4 ];
then
    rm -fr $HOME/data/pacbio/S288c_p6c4
fi
mkdir -p $HOME/data/pacbio/S288c_p6c4
cd $HOME/data/pacbio/S288c_p6c4
find $HOME/data/pacbio/rawdata/S288c/fasta -name "*.fasta" > input.fofn

cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 8000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 8000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 4
ovlp_concurrent_jobs = 4

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 2

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 2

EOF

#real    274m19.701s
#user    2202m51.987s
#sys     1737m17.436s
time fc_run fc_run.cfg

#N50     791352
#S       12094794
#C       39
faops n50 -S -C 2-asm-falcon/p_ctg.fa
```

## 其它模式生物

用这篇文章里提供的样例, doi:10.1038/sdata.2014.45.

# 其它相关的程序

## PacBio 自产

* HGAP: Hierarchical Genome Assembly Process，层次基因组组装, 以相对较长的读长数据为种子 (Seeding Reads),
  以相对较短的读长数据用于内部纠错. 这个时候得到的读长数据足够长也足够准确, 完全可以用于 de novo 组装,
  而无需二代数据帮忙.
* PBJelly: 用于gapclosing,
  [这里有简介.](https://github.com/alvaralmstedt/Tutorials/wiki/Gap-closing-with-PBJelly)

## 混合组装

* [DBG2LOC](http://www.nature.com/articles/srep31900) - 加上纯二代程序 Platanus (SOAP/ABySS)
* ectools: 用二代的 contigs 代替 reads 来校正三代
* LoRDEC - Celera Assembler
* [quickmerge](https://github.com/mahulchak/quickmerge) - 合并纯三代组装与二三代混合组装

# 中文资料

[生物通上有个专题](http://www.ebiotrade.com/custom/ebiotrade/zt/130503/index.htm), 有点老,
但基本的内容还是不错的.

生物通上近期还有两篇文章也挺好

* [韩国人基因组](http://www.ebiotrade.com/newsf/2016-10/2016108164502500.htm)
* [Atha Ler-0](http://www.ebiotrade.com/newsf/2016-9/201693094511949.htm)
