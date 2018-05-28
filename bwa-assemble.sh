# Assemble reads with reference genome using bwa

ref="Gfortis_genome/GeoFor_1.0_genomic.fna"
seqs="SRR_set_2.txt"

echo "Beginning alignment for " $seqs>>alignment_log.txt
echo "indexing reference">>alignment_log.txt

bwa index $ref

while read -r ID; do
echo "aligning " $ID >> alignment_log.txt

bwa mem -t 6 $ref "$ID"/"$ID"_trimmed_1P.fq.gz "$ID"/"$ID"_trimmed_2P.fq.gz | samtools view -b -o bam_files/$ID.bam -S

echo "sam file piped into samtools view to convert to .bam">>alignment_log.txt

done<"$seqs"

