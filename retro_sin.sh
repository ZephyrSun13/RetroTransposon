
#!/usr/bin/bash

set -e

Path=$(pwd)
BASEDIR=$(dirname "$0")

now=$(date +"%T")

echo "$now: Start pipeline ... "

source $Path/config.txt

#sed -i '1d' sample.txt

if [ ! -d $Temp ]
then

	mkdir $Temp

fi

awk -v Path="$Path" -v FQ_split_count="$FQ_split_count" -v Identity_percentage="$Identity_percentage" -v Identity_Support="$Identity_Support" -v Temp="$Temp" -v Clean="$Clean" '(NR>1 && !/^#/){

        #split($2, tt, "_");

	if(system("[ -f "Path"/"$2"/"$2".finished  ]") == 1 || system("[ -d "Path"/"$2" ]") == 1){

		if($3 == "PE"){

			if($4 == $5){

				printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && cp %s %s/%s/ && tar -xzvf %s/%s/*.gz -C %s/%s && rm -f %s/%s/*.gz && fq1=$(ls %s/%s/*_1.fastq) && fq2=$(ls %s/%s/*_2.fastq) && len=$(head -n 2 $fq1 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.V2/TEA_Sun.sh $fq1 $fq2 %s $len %s %s Paired %s %s %s 1> run.log 2> err.log && rm -f $fq1 && rm -f $fq2 \n", Path, $2, Path, $2, $4, Path, $2, Path, $2, Path, $2, Path, $2, Path, $2, Path, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

			}else{

				printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.V2/TEA_Sun.sh %s %s %s %s %s %s Paired %s %s %s 1> run.log 2> err.log \n", Path, $2, Path, $2, Path, $2, $4, $5, $2, $6, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

			}

		}

		else if($3 == "PE_bam"){

			printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && module load samtools/1.1 && samtools sort -n -T %s/%s/%s.tmp -o %s/%s/%s.bam %s && samtools bam2fq %s/%s/%s.bam | gzip > %s/%s/%s.fq.gz && rm -f %s/%s/%s.bam && fq1=%s/%s/%s.fq.gz && len=$(zcat $fq1 | head -n 2 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.V2/TEA_Sun.sh $fq1 $fq1 %s $len %s %s Sin %s %s %s 1> run.log 2> err.log && rm -f $fq1 \n", Path, $2, Path, $2, Path, $2, $2, Path, $2, $2, $4, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

		}

		else if($3 == "PE_sra"){

                        printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && module load sratoolkit/2.9.2 && fastq-dump -O %s/%s/ -F --split-files %s && fq1=%s/%s/%s_1.fastq && fq2=%s/%s/%s_2.fastq && len=$(cat $fq1 | head -n 2 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.V2/TEA_Sun.sh $fq1 $fq2 %s $len %s %s Paired %s %s %s 1> run.log 2> err.log && rm -f $fq1 && rm -f $fq2 \n", Path, $2, Path, $2, Path, $2, $4, Path, $2, $2, Path, $2, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

		}

		else{

			printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.V2/TEA_Sun.sh %s %s %s %s %s %s Sin %s %s %s 1> run.log 2> err.log \n", Path, $2, Path, $2, Path, $2, $4, $5, $2, $6, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

		}

	}

}' sample.txt > run_all.sh

if [ -s run_all.sh ]
then

	nohup /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/common/common/qsub-sge.pl --queue premium --pro_code acc_zhangw09a --reqsub --jobprefix $Title --resource 10000 --time 2440 --verbose --convert no --maxjob $Max_Job run_all.sh &

	if [ -d run_all.sh*.qsub ]
	then
	
	        rm -rf run_all.sh*.qsub
	
	fi
	
	c=1
	
	Total=$(wc -l < run_all.sh)
	
	Succ=0
	
	while [ $c -le 1008 ]
	do
	
	        if ls run_all.sh*.qsub/*.stdout 1> /dev/null 2>&1; then
	
	                Succ=$(grep 'Successfully completed' run_all.sh*.qsub/*.stdout | wc -l)
	
	        fi
	
	        if [ $Succ -lt $Total ]
	        then
	
	                (( c++ ))
	
	                echo "Round $c"
	
	                sleep 10m
	
	        else
	
	                break
	
	        fi
	
	done
	
	if ls run_all.sh*.qsub/*.stdout 1> /dev/null 2>&1; then
	
	        Succ=$(grep 'Successfully completed' run_all.sh*.qsub/*.stdout | wc -l)
	
	fi
	
	if [ $Succ -lt $Total ]
	then
	
	        echo >&2 "Some jobs are not finished"
	
	        exit 1
	
	fi

fi

now=$(date +"%T")

echo "$now: Start Summarize ... "

if [ -f All ]
then

        rm -f All

fi

#echo $Minimum_support_read

for ff in */Result.xls.merge.xls
do

        awk -F "\t" -v Minimum_support_read="$Minimum_support_read" '$4>Minimum_support_read' $ff > ${ff}.filtered

        #awk 'BEGIN{OFS="\t"} {print $1,$2,$8,$3,$5,$6}' ${ff}.filtered >> All

	awk 'BEGIN{FS="\t"; OFS="\t"} {print $1,$2,$3,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' ${ff}.filtered >> All

done

sort All | uniq > All.uniq && mv All.uniq All

sed -i '1d' All

for rr in */Result.xls.merge.xls
do

        awk 'BEGIN{OFS="\t"} (FNR==NR){a[$1]=$4;next}{if(a[$1]!=""){print $0,a[$1];}else{printf("%s\t0\n", $0)}}' $rr All > tmp

        mv tmp All

done

#export Minimum_sample

#perl -ne '$Ori = $_; chomp; @tt=split /\t/;@tt = @tt[ 13 .. $#tt ]; @tt = grep { $_>0 } @tt; if(($#tt+1) >= $ENV{Minimum_sample}){print $Ori}' All > All.filter && mv All.filter All

#awk -v len="$len" '{if($5-len+1<0){pos1=0}else{pos1=$5-len+1};printf("%s\t%d\t%d\n", $4, pos1, $5+len-1)}' All | sort | uniq > All.region

awk -v len="$len" '{split($5, tt, ";"); split($4, ttt, ";");if(tt[1]-len+1<0){pos1=0}else{pos1=tt[1]-len+1};printf("%s\t%d\t%d\n", ttt[1], pos1, tt[1]+len-1)}' All | sort | uniq > All.region

perl -ne 'if(/^>/){$_=~s/>//g;@tt=split(/ /, $_); if($tt[0] =~ /ref\|(.+)\.\d+\|/){$Sim=$1; print("$Sim\t$tt[0]\n")}}' /sc/arion/projects/zhangw09a/PANDA/db_ZS/Refseq/hg38/rna.fa > Ref_ID

awk 'BEGIN{FS="\t"; OFS="\t"}(FNR==NR){a[$1]=$2;next}{if(a[$1] != ""){print a[$1], $0}}' Ref_ID All.region | cut -f 1,3,4 > All.region.full

if [ -f summary_all.sh ]
then

        rm -f summary_all.sh

fi

Path=$(pwd)

for dd in $(ls */all.bam); do kk=${dd%/*}; printf "cd %s/%s && sh %s/summary.sh %s\n" "$Path" "$kk" "$BASEDIR" "$len" >> summary_all.sh; done

#for dd in $(ls */Result.xls); do kk=${dd%/*}; printf "cd %s/%s && sh %s/summary.sh %s\n" "$Path" "$kk" "$BASEDIR" "$len" >> summary_all.sh; done

if [ -d summary_all.sh*.qsub ]
then

        rm -rf summary_all.sh*.qsub

fi

Total=$(wc -l summary_all.sh)

Succ=0

c=1

/sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/common/common/qsub-sge.pl --queue premium --pro_code acc_zhangw09a --reqsub --jobprefix summary --resource 5000 --time 1440 --maxjob $Max_Job --verbose summary_all.sh &

while [ $c -le 300 ]
do

        if ls summary_all.sh*.qsub/*.stdout 1> /dev/null 2>&1; then

                Succ=$(grep 'Successfully completed' summary_all.sh*.qsub/*.stdout | wc -l)

        fi

        if [ $Succ -lt $Total ]
        then

                (( c++ ))

                echo "Round $c"

                sleep 10m

        else

                break

        fi

done

if ls summary_all.sh*.qsub/*.stdout 1> /dev/null 2>&1; then

        Succ=$(grep 'Successfully completed' summary_all.sh*.qsub/*.stdout | wc -l)

fi

if [ $Succ -lt $Total ]
then

        echo >&2 "Some jobs are not finished"

        exit 1

fi

ls -lG */all.region.full.count | awk '($4==0){system("rm -rf "$8)}'

for cc in */all.region.full.count
do

	if [ -s $cc ]
	then

        	awk 'BEGIN{OFS="\t"} (FNR==NR){tt=$1"_"$2;a[tt]=$3;next}{split($4,pp,";");split($5,ppp,";");ttt=pp[1]"_"ppp[1];if(a[ttt]!=""){print $0,a[ttt];}else{printf("%s\t0\n", $0)}}' $cc All > tmp

        	mv tmp All

	fi

done

printf "ID\nL1\nSymbol\nTranscript\nTrans_Split_Site\nL1_ID\nL1_split_site\nTrans_chromosome\nExon_num\nTrans_chromosom_split_site\nL1_chromosome\nL1_chromosom_split_site\nSequence\n" > All.head

ls */Result.xls.merge.xls | awk '{split($0, tt, "/"); print tt[1]}' >> All.head

ls */all.region.full.count | awk '{split($0, tt, "/"); printf ("%s_trans\n", tt[1])}' >> All.head

awk '{if(NR==1){printf("%s", $0)} else{printf("\t%s", $0)}} END{printf("\n")}' All.head > tmp && mv tmp All.head

cat All.head All > tmp && mv tmp All

awk -F "\t" '(NR>1){printf(">%s\n%s\n", $1, $13)}' All > All.fa 

#awk -F "\t" '(NR>1){split($13, tt, ";"); printf(">%s\n%s\n", $1, tt[1])}' All > All.fa

module load cd-hit/4.6.1 && cd-hit-est -i All.fa -o All.fa.clu -c 1 -n 10 -d 0 -M 3000 -T 2 -bak 1

perl -ne '@tt=split /\t/; if($tt[1] =~ />(\S+)\.\.\./){print "$tt[0]\t$1\n"}' All.fa.clu.bak.clstr > All.fa.clu.bak.clstr.sim

module load R/3.4.3 && Rscript $BASEDIR/merge.r All All.fa.clu.bak.clstr.sim 

#module load cd-hit/4.6.1 && cd-hit-est -i tmp.fa -o tmp.fa.clu -c 0.99 -n 10 -d 0 -M 3000 -T 2 -bak 1

#module load cd-hit/4.6.1 && cd-hit-est -i All.mapped.uniq.fa -o All.mapped.uniq.fa.clu -c 0.99 -n 10 -d 0 -M 3000 -T 2 -bak 1


#head -n 1 All > All.corrected

#perl $BASEDIR/CoordDup.pl All >> All.corrected

if [ -f All.sample.count ]
then

	rm -f All.sample.count

fi

for cc in */all.sam.count 
do

	if [ -s $cc ]
	then

		count=$(cat $cc)

		key=${cc%/*}

		printf "%s\t%s\n" "$key" "$count" >> All.sample.count
	
	fi	

done

#module load R/3.4.3 && Rscript $BASEDIR/norm.r All.corrected All.sample.count 

## V2, summarize events by sequence

#cut -f 1 All.corrected | perl -ne 'chomp; if(/(NC[^A-Z]+)_(N[MR][^A-Z]+)/){print("$_\t$1\t$2\n")}' > NC_NMR
#
#cut -f 2 NC_NMR | awk '{split($0, tt, "_"); printf("%s_%s\t%s\t%s\n", tt[1], tt[2], tt[3], tt[4])}' > NC_NMR_L1
#
#cut -f 3 NC_NMR | awk '{split($0, tt, "_"); printf("%s_%s\t%s\t%s\n", tt[1], tt[2], tt[3], tt[4])}' > NC_NMR_ref
#
#perl /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/extract.pl NC_NMR_L1 /sc/arion/projects/zhangw09a/Data/Zeguo_Sun/project/4.Retron/7.De_novo/4.library/Gene_L1_non_connected.fa FALSE > NC_NMR_L1.fa
#
#perl /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/extract.pl NC_NMR_ref /sc/arion/projects/zhangw09a/PANDA/db_ZS/Refseq/hg38/rna.fa FALSE | sed 's/>/_/g' > NC_NMR_ref.fa
#
#paste -d "" NC_NMR_L1.fa NC_NMR_ref.fa > NC_NMR.fa
#
#
#cut -f 1 All.corrected | perl -ne 'chomp; if(/(N[MR][^A-Z]+)_(NC[^A-Z]+)/){print("$_\t$1\t$2\n")}' > NMR_NC
#
#cut -f 2 NMR_NC | awk '{split($0, tt, "_"); printf("%s_%s\t%s\t%s\n", tt[1], tt[2], tt[3], tt[4])}' > NMR_NC_ref
#
#cut -f 3 NMR_NC | awk '{split($0, tt, "_"); printf("%s_%s\t%s\t%s\n", tt[1], tt[2], tt[3], tt[4])}' > NMR_NC_L1
#
#perl /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/extract.pl NMR_NC_ref /sc/arion/projects/zhangw09a/PANDA/db_ZS/Refseq/hg38/rna.fa FALSE > NMR_NC_ref.fa
#
#perl /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/extract.pl NMR_NC_L1 /sc/arion/projects/zhangw09a/Data/Zeguo_Sun/project/4.Retron/7.De_novo/4.library/Gene_L1_non_connected.fa FALSE | sed 's/>/_/g' > NMR_NC_L1.fa
#
#paste -d "" NMR_NC_ref.fa NMR_NC_L1.fa > NMR_NC.fa
#
#cat NC_NMR.fa NMR_NC.fa > merge.fa
#
#perl merge.pl merge.fa > merge.fa.tab
#
#awk '{print length($1)}' merge.fa.tab | sort | uniq -c | awk 'BEGIN{OFS = "\t"} {print $1, $2}' | sort -nr -k 1,1 > length.stat
#
#head -1 All.corrected | awk '{printf("Seq\t%s\n", $0)}' > All.corrected.merge.tab
#
#awk 'BEGIN{FS = "\t"; OFS = "\t"} (NR == FNR){tt[$2] = $1; next} {if(tt[$1] != ""){print tt[$1], $0}}' merge.fa.tab ../All.corrected | sort -k 1,1 >> All.corrected.merge.tab
#
#cut -f 1 All.corrected.merge.tab | sort | uniq -c | awk 'BEGIN{OFS= "\t"}{print $1, $2}' | sort -nr -k 1,1 > All.corrected.merge.tab.stat
#
#module load R/3.4.3 && Rscript $BASEDIR/merge.r
#
#awk '(NR>1){printf(">seq%05d\n%s\n", NR-1, $1)}' All.corrected.merge.tab.sum > All.corrected.merge.tab.fa
#
#module load cd-hit/4.6.1 && cd-hit-est -i All.corrected.merge.tab.fa -o All.corrected.merge.tab.fa100 -c 1 -n 10 -d 0 -M 2000 -T 2
#
##awk '{if(NR%2==1){gsub(">", "", $0); printf("%s\t", $0)} else{printf("%s\n", $0)}}' All.corrected.merge.tab.fa100 > All.corrected.merge.tab.fa100.tab
#
#grep -v '>' All.corrected.merge.tab.fa100 > All.corrected.merge.tab.fa100.tab
#
#head -1 All.corrected.merge.tab.sum > All.corrected.merge.tab.sum.clu
#
#awk '(NR==FNR){tt[$1]=1; next} {if(tt[$1] != ""){print $0}}' All.corrected.merge.tab.fa100.tab  All.corrected.merge.tab.sum >> All.corrected.merge.tab.sum.clu

## V.2

now=$(date +"%T")

echo "$now: Finished ... "

#cut -f 1,3,5,6 All | perl -ne '@tt=split /\t/; if($tt[0]=~/(NC\S+)_(N[MR]\S+)/){print("$1\t$tt[1]\t$tt[2]\t$tt[3]");} elsif($tt[0]=~/(N[MR]\S+)_(NC\S+)/){print("$2\t$tt[1]\t$tt[2]\t$tt[3]");} else{next;}' | awk '{split($1, tt, "_"); printf("%s_%s\t%s\t%s\t%s\n", tt[1], tt[2], $2, $3, $4)}' | le

#module load R/3.4.3 && Rscript merge.r Read.all.count All Files.ann.paired paired
#
#head -1 All.diff.xls > All.diff.selected.xls
#
#awk '($6 >= 1 && $7 <= 0.05 && $12 >= 1) || ($21 <= 0.05 && ($25 == "Inf" || $25 >= 1))' All.diff.xls >> All.diff.selected.xls

