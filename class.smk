import os
import glob
eukbam=glob.glob("*_euk_bin")
megadir = [os.path.basename(f).replace("euk_bin", "megahit") for f in eukbam]
samps=[os.path.basename(f).replace("_euk_bin","") for f in eukbam]
rule all:
  input:
    expand("{samp}_gtdb/gtdbtk.bac120.summary.tsv",samp=samps),
    expand("{samp}_gtdb/gtdbtk.ar122.summary.tsv",samp=samps),
    expand("{samp}_euk_pred/{samp}.faa",samp=samps),
    expand("{samp}_euk_pred/{samp}.fna",samp=samps),
    expand("{samp}_euk_pred/{samp}_scores.tsv",samp=samps)
rule drep:
  input:
    bacbins=directory("{samp}_bac.bin"),
    eukbins=directory("{samp}_euk_bin")
  output:
    bacdrep=directory("{samp}_bac_drep"),
    eukdrep=directory("{samp}_euk_drep")
  shell:
    '''
    dRep dereplicate {output.bacdrep} -g {input.bacbins}/*.fa
    dRep dereplicate {output.eukdrep} -g {input.eukbins}/*.fa
    '''
rule bactax:
  input:
    bacdrep="{samp}_bac_drep"
  output:
    directory("{samp}_gtdb"),
    gtbac="{samp}_gtdb/gtdbtk.bac120.summary.tsv",
    gtarc="{samp}_gtdb/gtdbtk.ar122.summary.tsv"
  shell:
    '''
    mkdir -p {output}
    export GTDBTK_DATA_PATH=/mnt/apps/users/kli/conda/envs/whokaryote/share/gtdbtk-2.1.1/db/release220/ 
    gtdbtk classify_wf --genome_dir {input.bacdrep} --out_dir {output[0]} --cpus 8 --extension .fa
    '''
rule eucpredict:
  input:
    eukdrep="{samp}_euk_drep"
  output:
    eukpep="{samp}_euk_pred/{samp}.faa",
    euknuc="{samp}_euk_pred/{samp}.fna",
    eukscore="{samp}_euk_pred/{samp}_scores.tsv"
  params:
    odir="{samp}_euk_pred",
    tmpdir="pred_tmp",
    uniref="/mnt/shared/projects/rbgk/users_area/kli/metaeuk/uniref90/UniRef90"
  resources:
    cpus=6
  shell:
    '''
    mkdir -p {params.tmpdir} {params.odir}
    metaeuk easy-predict --threads {resources.cpus} --split-memory-limit 60G {input.eukdrep}/*fa {params.uniref} {params.odir}/ {params.tmpdir}
    '''

