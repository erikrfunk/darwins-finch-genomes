# Batch download of SRA files 
# requires file with SRR ID listed 

filename="SRR_error_set.txt"
echo "SRR downloads for "$filename >> SRR_download_log.txt

while read -r ID
do
mkdir $ID
/opt/sratoolkit.2.9.0-ubuntu64/bin/fastq-dump --outdir $ID --skip-technical --read-filter pass --dumpbase --split-3 --clip $ID >>SRR_download_ log.txt
done<"$filename"
