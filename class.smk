import os
import glob
eukbam=glob.glob("*_euk_bin")
megadir = [os.path.basename(f).replace("euk_bin", "megahit") for f in eukbam]
samps=[os.path.basename(f).replace("_euk_bin","") for f in eukbam]
fnames=[os.path.basename(f).replace(".fa", "") for f in glob.glob("samp1_euk_bin/*.fa")]
rule all:
  input:
    expand("{samp}_gtdb/gtdbtk.bac120.summary.tsv",samp=samps),
    expand("{samp}_gtdb/gtdbtk.ar122.summary.tsv",samp=samps),
    expand("{samp}_euk_pred/{fname}.faa",samp=samps,fname=fnames),
    expand("{samp}_euk_pred/{fname}.fna",samp=samps,fname=fnames),
    expand("{samp}_euk_pred/{fname}_scores.tsv",samp=samps,fname=fnames)
rule bactax:
  input:
    bacdrep="{samp}_bac.bin"
  output:
    directory("{samp}_gtdb"),
    gtbac="{samp}_gtdb/gtdbtk.bac120.summary.tsv",
    gtarc="{samp}_gtdb/gtdbtk.ar122.summary.tsv"
  shell:
    '''
    export GTDBTK_DATA_PATH=/mnt/apps/users/kli/conda/envs/whokaryote/share/gtdbtk-2.1.1/db/release220/ 
    [ -d {output[0]} ] || mkdir -p {output[0]}
    gtdbtk classify_wf --genome_dir {input.bacdrep} --out_dir {output[0]} --cpus 8 --extension .fa --skip_ani_screen
    '''
rule eucpredict:
  input:
    eukdrep="{samp}_euk_bin/{fname}.fa"
  output:
    eukpep="{samp}_euk_pred/{fname}.faa",
    euknuc="{samp}_euk_pred/{fname}.fna",
    eukscore="{samp}_euk_pred/{fname}_scores.tsv"
  params:
    odir="{samp}_euk_pred",
    tmpdir="pred_tmp",
    uniref="/mnt/shared/projects/rbgk/users_area/kli/metaeuk/uniref90/UniRef90"
  resources:
    cpus=6
  shell:
    '''
    mkdir -p {params.tmpdir} {params.odir}
    /mnt/shared/projects/rbgk/users_area/kli/metaeuk/bin/metaeuk easy-predict --threads {resources.cpus} --split-memory-limit 30G {input.eukdrep} {params.uniref} {params.odir} {params.tmpdir}
    '''

