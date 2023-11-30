/*
 * Sort VCF 
 */

process sortVcf {
  tag "${sampleName}"
  label 'bcftools'
  label "medCpu"
  label "medMem"

  input:
  val sampleName
  path annotVcf
  
  output:
  path("*.sorted.vcf"), emit: sortedVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  bcftools sort ${annotVcf} > \$(basename ${annotVcf} .vcf).sorted.vcf  

  """
}


