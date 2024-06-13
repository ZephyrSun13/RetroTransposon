 
#!/usr/bin/bash

len=$1

set -e

if [ -f all.bam ]
then

	module load samtools/1.1
	
	samtools view -h -F 4 -L ../All.region.full all.bam > all.region.sam
	
	/sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/samclip/samclip/samclip --max 2 --ref /sc/arion/projects/zhangw09a/PANDA/db_ZS/Refseq/hg38/rna.fa all.region.sam > all.region.sam.no.clip
	
	rm -f all.region.sam
	
	samtools view -b all.region.sam.no.clip > all.region.sam.no.clip.bam
	
	rm -f all.region.sam.no.clip
	
	samtools sort all.region.sam.no.clip.bam all.region.sam.no.clip.bam.sorted
	
	rm -f all.region.sam.no.clip.bam
	
	samtools index all.region.sam.no.clip.bam.sorted.bam
	
	#echo $len
	
	awk -v len="$len" '{tt=$1":"$2"-"$3; cmd = "samtools view -c all.region.sam.no.clip.bam.sorted.bam \""tt"\""; cmd | getline Count; printf("%s\t%s\t%s\t%s\n", $1, $2, $3, Count); close(cmd)}' ../All.region.full | awk -v len="$len" '{split($1, tt, "|"); split(tt[2], ttt, "."); printf("%s\t%s\t%s\n", ttt[1], ($3-len+1), $4)}' > all.region.full.count
	
	rm -f all.region.sam.no.clip.bam.sorted.bam*

fi

