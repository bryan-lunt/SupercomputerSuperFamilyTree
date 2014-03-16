#/bin/bash

source ${SFT_BIN}/SETTINGS.sh

cd $PBS_O_WORKDIR

#get unique group names
cat groups.txt | awk '{print $2;}' | sort | uniq > unique_group_names.txt

mkdir -p faaOut_grouped

for GROUPNAME in $(cat unique_group_names.txt)
do
	for ONESEQNAME in $(cat groups.txt | awk -vgname=${GROUPNAME} '$2 == gname {print $1;}' | sort | uniq)
	do
		ONEFILENAME=$(cat rename.txt | awk -vsname=${ONESEQNAME} '$2 == sname {print $1;}')
		cat faaOut/${ONEFILENAME}.faa >> faaOut_grouped/${GROUPNAME}.faa
	done
done

#Now we have all the groups, but those names might be too long for PHYLIP.
#rename the groups group_1 group_2 group_3

ls faaOut_grouped | sed 's/\.faa$//' | awk 'START {id=0;} {id++; print "grp_"id,$1;}' > rename_groups.txt

cat rename_groups.txt | while read NEWGNAME ORIGGNAME
do
	mv faaOut_grouped/${ORIGGNAME}.faa faaOut_grouped/${NEWGNAME}.faa
done

mv rename.txt rename.txt.sft1
cp rename_groups.txt rename.txt
mv faaOut faaOut_sft1
mv faaOut_grouped faaOut

#TODO:we still need to uniquify the sequences in each file....
