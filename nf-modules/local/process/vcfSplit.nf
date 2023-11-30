/*
 * Split vcf 
 */

process vcfSplit {
  tag "${sampleName}"
  label 'gatk_bam_readcount'
  label "medCpu"
  label "medMem"

  input:
  val sampleName
  path exprVcf
  path vt
  path fasta
  path fastaIndex
  path fastaDict
  path sampleRnaBam
  path sampleRnaBamIndex
  
  output:
  path("*vt.snv.vcf"), emit: splitSnvVcf
  path("*vt.indel.vcf"), emit: splitIndelVcf
  path("*vt.readcount.snv.txt"), emit: splitSnvTxt
  path("*vt.readcount.indel.txt"), emit: splitIndelTxt

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  declare prefix=\$(basename ${exprVcf} .vcf)

  # first split multi-allelic sites 
  
  ./${vt} decompose -s ${exprVcf} -o \${prefix}.vt.vcf 
 

  # add readcount information 

  gatk SelectVariants -R ${fasta} -V \${prefix}.vt.vcf  --select-type-to-include SNP -O \${prefix}.vt.snv.vcf
  gatk SelectVariants -R ${fasta} -V \${prefix}.vt.vcf  --select-type-to-include INDEL -O \${prefix}.vt.indel.vcf

  awk '{FS="\t"; OFS="\t"}{if(\$0 !~ /#/) print \$1,\$2,\$2}' \${prefix}.vt.snv.vcf > \${prefix}.vt.snv.list
  awk '{FS="\t"; OFS="\t"}{if(\$0 !~ /#/) print \$1,\$2,\$2+length(\$5)-1}' \${prefix}.vt.indel.vcf > \${prefix}.vt.indel.list

  bam-readcount -w1 -f ${fasta} -l \${prefix}.vt.snv.list  ${sampleRnaBam}  > \${prefix}.vt.readcount.snv.txt 
  bam-readcount -w1 -f ${fasta} -l \${prefix}.vt.indel.list  ${sampleRnaBam} -i > \${prefix}.vt.readcount.indel.txt 


  """
}
