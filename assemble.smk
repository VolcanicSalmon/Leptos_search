import os
import glob 
acc=glob.glob("*_1.fastq.gz")
samples={os.path.basename(f).split("_1.fastq.gz")[0] for f in acc}
print(samples)
rule all:
  input:
    expand("megahit/{sample}/euk.contigs.fa",sample=samples),
    expand("megahit/{sample}/prok.contigs.fa",sample=samples)
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
  shell:
    "{params.bbduk} -Xmx11g in1={input.fw} in2={input.rv} out1={output.fw} out2={output.rv} trimq=10 maq=10 ref=adapters.fa"
rule megahit:
  input:
    fw="{sample}_1.dedu.fastq.gz",
    rv="{sample}_2.dedu.fastq.gz"
  output:
    assembly="megahit/{sample}/final.contigs.fa"
  shell:
    "megahit -1 {input.fw} -2 {input.rv} -o {output.assembly} -t 12"
rule eukrep:
  input:
    assembly="megahit/{sample}/final.contigs.fa"
  output:
    eukfa="megahit/{sample}/euk.contigs.fa",
    prokfa="megahit/{sample}/prok.contigs.fa"
  shell:
    "EukRep -i {input.assembly} -o {output.eukfa} --prokarya {output.prokfa}"
