files_not_needed="SRR_set_remove.txt"

while read -r SRR; do
rm "$SRR"/*
rmdir $SRR
done<"$files_not_needed"

