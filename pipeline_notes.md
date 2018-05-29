Notes on Darwin's finches genome re-analysis

Files and analyses run on Taylor lab server 'Chickadee' in data2/PracticeGenomes

--------------------------------------------------------------------------------

1 - Sequences were downloaded from the SRA using the SRA-toolkit

commands for download were as follows: 

	fastq-dump --outdir --skip-technical --read-filter pass --dumpbase --split-3 --clip SSR_ID

batched processed using "SRA-fetch.sh" 
SSR_ID's placed in "SSR_set_*.txt"
screen output saved in SRR_download_log.txt
	
	Do not use --readid flag!! creates different names for each read and causes problems with bwa mem downstream


-- Steps 2-4 combined into "trim-and-QC.sh" --
	
2 - Quality report generated using fastqc

batch processed using "pretrim-QC.sh" 
screen output saved in pre_trim_QC_log.txt
files saved in pre_trim_QC_files/

need to think about the best course of action here. Is it feasible to QC every sequence before AND after trimming? Or should maybe just check QC after the trimming step (can run fastQC before and after, but maybe just check it after)


3 - Trimming sequences using TrimmomaticPE 

	TrimmomaticPE -threads 6 \
	-basein SRRID_pass_1.fastq \
	-baseout SRRID_trimmed.fq.gz \
	ILLUMINACLIP:TruSeq3-PE.fa:1:30:10 \
	LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:90 


4 - Post trim QC

used same qc command as step 2, but saved all output in designated directory

batch processed using posttrim-QC.sh
files saved in post_trim_QC_files/


5 - Reference guided assembly using bwa mem

first indexed the reference genome	
output from assembly was piped into SAMtools view to convert.sam file into .bam file 

processed using bwa-assemble.sh


6 - Merge, Sort, and Index .bam files

All functions in this step performed by merge-bam-files.sh
--run this inside the directory containing bam files

merged unsorted .bam files corresponding to a single sample using 
samtools cat -o 

then sorted the merged .bam file using 
	samtools sort -o sorted_bam_file/samplename.bam -T temp -@ 6 

Added read group information --
	picard-tools AddOrReplaceReadGroups \
	I=input/path/to/file O=output/dir \
	RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=$SAMPLE

Marked duplicates --
	picard-tools MarkDuplicates I= sampID_sorted.bam O= sampID_sorted_dupmarked.bam M= sampID_dupmarked_metrics.txt

finally indexed using sorted bam file - .bai files in same folder as sorted .bam
samtools index 

7 - Haplotype Calling and Variant Discovery

must create a reference genome dictionary and indexed fasta
picard-tools CreateSequenceDictionary R=GeoFor_1.0_genomic.fna \
O= GeoFor_1.0_genomic.dict

then index the reference fasta
samtools faidx GeoFor_1.0_genomic.fna

Haplotype calling done using GATK v4 HaplotypeCaller with the -ERC GVFC flag

	gatk HaplotypeCaller \
   	-R reference.fasta \
   	-I bamfile \
   	-O output.g.vcf.gz \  
   	-ERC GVCF

8 - Merging and Genotyping

per sample gvcf files created by HaplotypeCaller are first merged 
	gatk CombineGVCFs \
	-R reference.fasta \
	-V sample1.g.vcf.gz \
	-V sample2.g.vcf.gz \ ...
	-O cohort.g.vcf.gz

then perform genotyping on this merged gvcf
	gatk GenotypeGVCFs \
	-nt 6 \ # not sure if this flag is still supported with GATK4
	-R reference.fasta \
	-V input.g.vcf.gz \
	-O output.vcf.gz 

9 - Filtering Variants

Likely to be a lot of variation in this step depending on what we want to do
For the first set, will filter out annotations according to the gatk recommended settings below
Will also create a set that includes only the resulting SNPs for phylogenomic analysis 


variants then hard filtered using 
Recommendations by gatk
Visualize the distribution of annotation values?
QualByDepth (QD): filter out variants with QD below 2
FisherStrand (FS): filter out variants with FS greater than 60
	or SOR value less than 3
RMSMappingQuality (MQ): filter out variants with MQ less than 40
MappingQualityRankSumTest (MQRankSum): filter out variants less than -12.5
ReadPosRankSumTest (ReadPosRankSum): filter out variants less than -8.0

filtration called using SelectVariants
	gatk SelectVariants \
	-R reference.fasta \
	-V input.vcf \
	-o output.vcf \
	-select "QD > 2" \
	-select "FS < 60" \
	-select "MQ > 40" \
	-select "MQRankSum > -12.5" \
	-select "ReadPosRankSum > -8.0" \
	--select-type-to-include SNP 
	--exclude-filtered \ # won't include filtered sites
	--exclude-non-variants # won't include non-variant sites

tallied number of SNPs kept using
	gatk VariantsToTable -V input.vcf -F CHROM -F POS -F TYPE -O output.table

10 - Phasing with Beagle

	java -Xmx4g -jar ~/beagle.16May18.771.jar gt=path/to/genotype/file.vcf out=out_prefix

could look into specifying genetic map length (I think the recomb. in zebra finch is like 1.5cM?)

----------------------------------
Next Steps or other considerations
----------------------------------

PCA of SNPs
NGSadmix
SVDquartets
