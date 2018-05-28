# shell script for pre-trim QC, trimming, and post-trim QC
# pre and post trim QC files go to separate directories

filename="SRR_set_2.txt"

echo "Trim and QC for "$filename>>trim_and_QC_log.txt

while read -r ID; do
echo "Beginning pre-trim QC for "$ID>>trim_and_QC_log.txt
fastqc -t 6 "$ID"/"$ID"_pass_1.fastq "$ID"/"$ID"_pass_2.fastq --outdir=pre_trim_QC_files/
echo $ID" pre-trim QC done" >> trim_and_QC_log.txt

echo "Beginning trimming for "$ID>>trim_and_QC_log.txt
TrimmomaticPE -threads 6 -basein "$ID"/"$ID"_pass_1.fastq -baseout "$ID"/"$ID"_trimmed.fq.gz LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:90>>trim_and_QC_log.txt

echo "Beginning post-trim for "$ID>>trim_and_QC_log.txt
fastqc -t 6 "$ID"/"$ID"_trimmed_1P.fq.gz "$ID"/"$ID"_trimmed_2P.fq.gz --outdir post_trim_QC_files/
echo $ID" post-trim QC done">>trim_and_QC_log.txt

done<"$filename"
