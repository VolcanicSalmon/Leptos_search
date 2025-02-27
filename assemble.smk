import os
import glob 
acc=glob.glob("*_1.fastq.gz")
samples = [os.path.basename(f).replace("_1.fastq.gz", "") for f in acc]
print(samples)
rule all:
  input:
    expand("{sample}_euk/euk.contigs.fa",sample=samples),
    expand("{sample}_prok/prok.contigs.fa",sample=samples)
rule bbduk:
  input:
    fw="{sample}_1.fastq.gz",
    rv="{sample}_2.fastq.gz"
  log:
    "{sample}_bbduk.log"
  output:
    fw="{sample}_1.dedu.fastq.gz",
    rv="{sample}_2.dedu.fastq.gz"
  params:
    bbduk="/mnt/shared/projects/rbgk/users_area/kli/bbmap/bbduk.sh"
  group: "bbduk_batch"
  shell:
    "{params.bbduk} -Xmx12g in1={input.fw} in2={input.rv} out1={output.fw} out2={output.rv} trimq=10 maq=10 ref=adapters.fa"
rule megahit:
  input:
    fw="{sample}_1.dedu.fastq.gz",
    rv="{sample}_2.dedu.fastq.gz"
  output:
    assemblydir="megahit/{sample}",
    assembly="megahit/{sample}/final.contigs.fa"
  group: "megahit_batch"
  shell:
    "megahit -1 {input.fw} -2 {input.rv} -o megahit/{wildcards.sample} -t 12 -m 20e9"
rule eukrep:
  input:
    assembly="megahit/{sample}/final.contigs.fa"
  output:
    eukfa="{sample}_euk/euk.contigs.fa",
    prokfa="{sample}_prok/prok.contigs.fa"
  shell:
    "EukRep -i {input.assembly} -o {output.eukfa} --prokarya {output.prokfa}"
