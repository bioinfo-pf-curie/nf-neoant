/*
 * Split vcf 
 */

process vcfSplit {
  tag "${meta.sampleName}"
  label 'gatk_bam_readcount'
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(exprVcf), path(sampleRnaBam), path(sampleRnaBamIndex)
  path vt
  path fasta
  path fastaIndex
  path fastaDict

  output:
  tuple val(meta), path("*vt.snv.vcf"),path("*vt.indel.vcf"),path("*vt.readcount.snv.txt"),path("*vt.readcount.indel.txt"), emit: splitVcf

  script:
  """

  declare prefix=\$(basename ${exprVcf} .vcf)

  # first split multi-allelic sites 
  
  bcftools norm -m - ${exprVcf} > \${prefix}.vt.vcf 
 
  # add readcount information 

  gatk SelectVariants -R ${fasta} -V \${prefix}.vt.vcf  --select-type-to-include SNP -O \${prefix}.vt.snv.vcf
  gatk SelectVariants -R ${fasta} -V \${prefix}.vt.vcf  --select-type-to-include INDEL -O \${prefix}.vt.indel.vcf

  awk '{FS="\t"; OFS="\t"}{if(\$0 !~ /#/) print \$1,\$2,\$2}' \${prefix}.vt.snv.vcf > \${prefix}.vt.snv.list
  awk '{FS="\t"; OFS="\t"}{if(\$0 !~ /#/) print \$1,\$2,\$2+length(\$5)-1}' \${prefix}.vt.indel.vcf > \${prefix}.vt.indel.list

  bam-readcount -w1 -f ${fasta} -l \${prefix}.vt.snv.list  ${sampleRnaBam}  > \${prefix}.vt.readcount.snv.txt 
  bam-readcount -w1 -f ${fasta} -l \${prefix}.vt.indel.list  ${sampleRnaBam} -i > \${prefix}.vt.readcount.indel.txt 


  """
}
