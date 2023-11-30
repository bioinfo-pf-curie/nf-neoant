/*
 * Add RNA coverage to VCF 
 */

process vcfAddRnaCov {
  tag "${sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"

  input:
  val sampleName
  path splitSnvVcf
  path splitIndelVcf
  path splitSnvTxt
  path splitIndelTxt
  
  output:
  path("*vt.annot.vcf"), emit: rnaCovVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  vcf-readcount-annotator -s ${sampleName} -t snv -o ${sampleName}.vt.snv.rna.vcf ${splitSnvVcf} ${splitSnvTxt}  RNA 
  vcf-readcount-annotator -s ${sampleName} -t indel -o ${sampleName}.vt.indel.rna.vcf ${splitIndelVcf} ${splitIndelTxt}  RNA 

  grep "^#\\|:RAF" ${sampleName}.vt.snv.rna.vcf  > ${sampleName}.vt.annot.vcf 
  grep ":RAF" ${sampleName}.vt.snv.rna.vcf  >> ${sampleName}.vt.annot.vcf 


  """
}


