#!/bin/bash

eukin=($(ls -d ER*euk_bin | sed -n ${SLURM_ARRAY_TASK_ID}p))

for i in $eukin/*.fa; do
    odir=${i%%.fa}_metaeuk
    tdir=${i%%.fa}_tmp
    /mnt/shared/projects/rbgk/users_area/kli/metaeuk/bin/metaeuk easy-predict \
        --threads 4 --comp-bias-corr 1 --diag-score 1 --split-memory-limit 40G \
        $i \
        ../metaeuk/uniref90/UniRef90 \
        $odir $tdir

    # Define paths for taxonomic annotation
    tdir2=${i%%.fa}_tmp2
    fdir=${i%%.fa}_tax
    contigdb=${i%%.fa}_tmp/latest/contigs
    if [ -d $contigdb ]; then
        /mnt/shared/projects/rbgk/users_area/kli/metaeuk/bin/metaeuk taxtocontig \
            $contigdb \
            ${odir}.fas ${odir}.headersMap.tsv \
            ../metaeuk/uniref90/UniRef90 \
            $fdir $tdir2 \
            --majority 0.5 --tax-lineage 2 --lca-mode 2 --threads 4
    else
        echo "$i contigdb missing"
    fi
done
