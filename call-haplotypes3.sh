# input name of sample and path to sorted, duplicate marked, RG added bam file

sample="T3"

gatk HaplotypeCaller \
-R /data2/PracticeGenomes/Gfortis_genome/GeoFor_1.0_genomic.fna \
-I /data2/PracticeGenomes/bam_files/sorted_bam_files/"$sample"_sorted_RGadded_dupmarked.bam \
-O /data2/PracticeGenomes/vcf_files/"$sample".g.vcf.gz \
-ERC GVCF
