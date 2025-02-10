for i in *.faa; do awk '/^>/ {print ">" $2 substr($0,index($0,$3))} !/^>/ {print $0}' $i > ${i//faa/rn.faa}; done
for i in *rn.faa; do sed -E 's/ PE=[^ ]*//i' $i > ${i//rn.faa/rn2.faa}; done
for i in *rn2.faa; do sed -E 's/ SV=[^ ]*//i' $i > ${i//rn.faa/rn2.faa}; done
for i in *rn.faa; do sed -E 's/ PE=[^ ]*//i' $i > ${i//rn.faa/rn2.faa}; done
for i in *rn2.faa; do sed -E 's/ SV=[^ ]*//i' $i > ${i//rn2.faa/rn3.faa}; done
for i in *rn3.faa; do sed -E 's/ OX=[^ ]*//i' $i > ${i//rn3.faa/rn4.faa}; done
sed -i 's/ OS=/|/g' *rn4.faa
sed -i 's/ GN=/|/g' *rn4.faa

#!/bin/bash

fa=($(ls *rn4.faa | sed -n ${SLURM_ARRAY_TASK_ID}p))
db=$(echo $fa | sed 's/rn4.faa//')
diamond makedb --in $fa -d $db
