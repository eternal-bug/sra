# Processing NCBI sra/EBI ena data

## Projects

### medfood: medicine food homology. Rna-seq survey.

Download.

```bash
cd ~/Scripts/sra
perl medfood_info.pl

perl sra_prep.pl -i medfood.yml --md5

mkdir -p ~/data/rna-seq/medfood/sra
cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.ftp.txt .
aria2c -x 9 -s 3 -c -i medfood.ftp.txt

cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.md5.txt .
md5sum --check medfood.md5.txt
```

ENA didn't display DRX correctly, so manually downlaod files and add information for DRX026628 and DRX014826.

Use `prefetch` of sra toolkit to download DRR files.

```bash
prefetch DRR029569 DRR029570 DRR016460

mv ~/ncbi/public/sra/DRR*.sra ~/data/rna-seq/medfood/sra
```

* http://www.ncbi.nlm.nih.gov/sra/?term=DRX026628
* http://www.ncbi.nlm.nih.gov/sra/?term=DRX014826

```bash
cd ~/Scripts/sra

echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029569,4000000,808M >> medfood.csv
echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029570,2135878,431.4M >> medfood.csv

echo Pueraria_lobata,DRX014826,ILLUMINA,PAIRED,101,DRR016460,23802502,2.4G >> medfood.csv
```
