#adapt from u:stsmall
import re 
from operator import itemgetter
from itertools import groupby
import argparse
parser=argparse.ArgumentParser()
parser.add_argument('-f','--fasta',type=str,required=True,help='fastaname')
args=parser.parse_args()
def make_negmaskbed(maskedfa):
    f=open(maskedfa,+'_maskregion.bed','w')
    with open(maskedfa,'r') as fasta:
        for line in fasta:#iterate 
            if line.startswith(">"):
                contig=line.strip(">\n")#removes the > symbol, store the contig name
                length=0 
            else:
                line=line.rstrip("\n")
                bedloc=[m.start() for m in re.finditer("[agtcnN]",line)]
                #find the lowercase masked bases or Ns in the sequences
                #[agtcnN]=bases of interest, possibly masked, ambiguous
                ranges=[]#store the ranges of consecutive positions matching the pattern
                for k,g in grouppby(enumerate(bedloc),lambda ix: ix[0] - ix[1]):
                    #groups the consecutive bases 
                    group=map(itemgetter(1),g)
                    ranges.append((group[0]+length,group[-1]+length))
                length+=len(line)
                for item in ranges:
                    if len(item)>1:
                        f.write("{}\t{}\t{}\n".format(contig,item[0],item[1]+1))
                    else:
                        f.write("{}\t{}\t{}\n".format(contig,item[0],item[0]+1))
        f.close()
def make_posmaskbed(maskedfa):
    f=open(maskedfa+'nonmaskregion.bed','w')
    with open(maskedfa,'r') as fasta:
        for line in fasta:
            if line.startswith(">"):
                contig=line.strip(">\n")
                length=0 
            else:
                line=line.rstrip("\n")
                bedloc=[m.start() for m in re.finditer("[AGTC]",line)]
                ranges=[]
                for k,g in groupby(enumerate(bedloc),lambda ix: ix[0] - ix[1]):
                    group=map(itemgetter(1),g)
                    ranges.append((group[0]+length,group[-1]+length))
                length+=len(line)
                for item in ranges:
                    if len(item)>1:
                        f.write("{}\t{}\t{}\n".format(contig,item[0],item[1]+1))
                    else:
                        f.write("{}\t{}\t{}\n".format(contig,item[0],item[0]+1))
    f.close()

if __name__=='__main__':
    make_negmaskbed(args.fasta)
    make_posmaskbed(args.fasta)
