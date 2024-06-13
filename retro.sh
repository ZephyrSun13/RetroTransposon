
#!/usr/bin/bash

set -e

Path=$(pwd)
BASEDIR=$(dirname "$0")

now=$(date +"%T")

echo "$now: Start pipeline ... "

source $Path/config.txt

if [ ! -d $Temp ]
then

	mkdir $Temp

fi

awk -v Path="$Path" -v FQ_split_count="$FQ_split_count" -v Identity_percentage="$Identity_percentage" -v Identity_Support="$Identity_Support" -v Temp="$Temp" -v Clean="$Clean" '(NR>1 && !/^#/){

        #split($2, tt, "_");

	if(system("[ -f "Path"/"$2"/"$2".finished  ]") == 1 || system("[ -d "Path"/"$2" ]") == 1){

		if($3 == "PE"){

			if($4 == $5){

				printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && cp %s %s/%s/ && tar -xzvf %s/%s/*.gz -C %s/%s && rm -f %s/%s/*.gz && fq1=$(ls %s/%s/*_1.fastq) && fq2=$(ls %s/%s/*_2.fastq) && len=$(head -n 2 $fq1 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.v8/TEA_Sun.sh $fq1 $fq2 %s $len %s %s Paired %s %s %s 1> run.log 2> err.log && rm -f $fq1 && rm -f $fq2 \n", Path, $2, Path, $2, $4, Path, $2, Path, $2, Path, $2, Path, $2, Path, $2, Path, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

			}else{

				printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.v8/TEA_Sun.sh %s %s %s %s %s %s Paired %s %s %s 1> run.log 2> err.log \n", Path, $2, Path, $2, Path, $2, $4, $5, $2, $6, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

			}

		}

		else if($3 == "PE_bam"){

			printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && module load samtools/1.1 && samtools sort -n -T %s/%s/%s.tmp -o %s/%s/%s.bam %s && samtools bam2fq %s/%s/%s.bam | gzip > %s/%s/%s.fq.gz && rm -f %s/%s/%s.bam && zcat %s/%s/%s.fq.gz | grep \"^@.*/1$\" -A 3 --no-group-separator | gzip > %s/%s/%s_1.fq.gz && zcat %s/%s/%s.fq.gz | grep \"^@.*/2$\" -A 3 --no-group-separator | gzip > %s/%s/%s_2.fq.gz && rm -f %s/%s/%s.fq.gz && fq1=%s/%s/%s_1.fq.gz && fq2=%s/%s/%s_2.fq.gz && len=$(zcat $fq1 | head -n 2 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.v8/TEA_Sun.sh $fq1 $fq2 %s $len %s %s Paired %s %s %s 1> run.log 2> err.log && rm -f $fq1 && rm -f $fq2\n", Path, $2, Path, $2, Path, $2, $2, Path, $2, $2, $4, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

		}

		else if($3 == "PE_sra"){

                        printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && module load sratoolkit/2.9.2 && fastq-dump -O %s/%s/ -F --split-files %s && fq1=%s/%s/%s_1.fastq && fq2=%s/%s/%s_2.fastq && len=$(cat $fq1 | head -n 2 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.v8/TEA_Sun.sh $fq1 $fq2 %s $len %s %s Paired %s %s %s 1> run.log 2> err.log && rm -f $fq1 && rm -f $fq2 \n", Path, $2, Path, $2, Path, $2, $4, Path, $2, $2, Path, $2, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

		}

                else if($3 == "SE_sra"){

                        printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && module load sratoolkit/2.9.2 && fastq-dump -O %s/%s/ -F %s && fq1=%s/%s/%s.fastq && len=$(cat $fq1 | head -n 2 | tail -n 1 | wc -c) && len=$(($len-1)) && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.v8/TEA_Sun.sh $fq1 $fq1 %s $len %s %s Sin %s %s %s 1> run.log 2> err.log && rm -f $fq1 \n", Path, $2, Path, $2, Path, $2, $4, Path, $2, $2, Path, $2, $2, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

                }

		else{

			printf("if [ ! -d %s/%s ];then mkdir %s/%s; fi && cd %s/%s && /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/code/TEA_Sun.v8/TEA_Sun.sh %s %s %s %s %s %s Sin %s %s %s 1> run.log 2> err.log \n", Path, $2, Path, $2, Path, $2, $4, $5, $2, $6, FQ_split_count, Temp, Identity_percentage, Identity_Support, Clean)

		}

	}

}' sample.txt > run_all.sh

if [ -s run_all.sh ]
then

	nohup /sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/common/common/qsub-sge.pl --queue premium --pro_code acc_zhangw09a --reqsub --jobprefix $Title --resource 20000 --time 1440 --verbose --convert no --maxjob $Max_Job run_all.sh &

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

for ff in */Result.xls.merge.cov.xls
do

        awk -F "\t" -v Minimum_support_read="$Minimum_support_read" '$4>Minimum_support_read' $ff > ${ff}.filtered

	awk 'BEGIN{FS="\t"; OFS="\t"} {print $1,$2,$3,$5,$6,$7,$8,$9,$10,$11,$12,$13,$15}' ${ff}.filtered >> All

done

sort All | uniq > All.uniq && mv All.uniq All

sed -i '1d' All

for rr in */Result.xls.merge.cov.xls
do

        awk 'BEGIN{OFS="\t"} (FNR==NR){a[$1]=$4;next}{if(a[$1]!=""){print $0,a[$1];}else{printf("%s\t0\n", $0)}}' $rr All > tmp

        mv tmp All

done

#export Minimum_sample

awk -v len="$len" '{split($5, tt, ";"); split($4, ttt, ";");if(tt[1]-len+1<0){pos1=0}else{pos1=tt[1]-len+1};printf("%s\t%d\t%d\n", ttt[1], pos1, tt[1]+len-1)}' All | sort | uniq > All.region

perl -ne 'if(/^>/){$_=~s/>//g;@tt=split(/ /, $_); if($tt[0] =~ /ref\|(.+)\.\d+\|/){$Sim=$1; print("$Sim\t$tt[0]\n")}}' /sc/arion/projects/zhangw09a/PANDA/db_ZS/Refseq/hg38/rna.fa > Ref_ID

awk 'BEGIN{FS="\t"; OFS="\t"}(FNR==NR){a[$1]=$2;next}{if(a[$1] != ""){print a[$1], $0}}' Ref_ID All.region | cut -f 1,3,4 > All.region.full

if [ -f summary_all.sh ]
then

        rm -f summary_all.sh

fi

Path=$(pwd)

for dd in $(ls */all.bam); do kk=${dd%/*}; if [ ! -s $kk/all.region.full.count ]; then printf "cd %s/%s && sh %s/summary.sh %s\n" "$Path" "$kk" "$BASEDIR" "$len" >> summary_all.sh; fi; done

if [ -s summary_all.sh ]
then

	if [ -d summary_all.sh*.qsub ]
	then
	
	        rm -rf summary_all.sh*.qsub
	
	fi
	
	Total=$(wc -l < summary_all.sh)
	
	Succ=0
	
	c=1
	
	/sc/arion/projects/zhangw09a/PANDA/ext_ZS/bin/common/common/qsub-sge.pl --queue premium --pro_code acc_zhangw09a --reqsub --jobprefix summary --resource 5000 --time $WallTime --maxjob $Max_Job --verbose summary_all.sh &
	
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

ls */Result.xls.merge.cov.xls | awk '{split($0, tt, "/"); print tt[1]}' >> All.head

ls */all.region.full.count | awk '{split($0, tt, "/"); printf ("%s_trans\n", tt[1])}' >> All.head

awk '{if(NR==1){printf("%s", $0)} else{printf("\t%s", $0)}} END{printf("\n")}' All.head > tmp && mv tmp All.head

cat All.head All > tmp && mv tmp All

awk -F "\t" '(NR>1){printf(">%s\n%s\n", $1, $13)}' All > All.fa 

#module load cd-hit/4.6.1 && cd-hit-est -i All.fa -o All.fa.clu -c 1 -n 10 -d 0 -M 3000 -T 2 -bak 1

module load cd-hit/4.6.1 && cd-hit-est -i All.fa -o All.fa.clu -c 0.99 -n 10 -d 0 -M 3000 -T 2 -bak 1

perl -ne '@tt=split /\t/; if($tt[1] =~ />(\S+)\.\.\./){print "$tt[0]\t$1\n"}' All.fa.clu.bak.clstr > All.fa.clu.bak.clstr.sim

module load R/3.4.3 && Rscript $BASEDIR/merge.r All All.fa.clu.bak.clstr.sim 

module load R/3.4.3 && Rscript $BASEDIR/plot2.r 3 


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

## V.2

now=$(date +"%T")

echo "$now: Finished ... "

