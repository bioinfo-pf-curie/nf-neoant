/*
 * Sort VCF 
 */

process sortVcf {
  tag "${meta.sampleName}"
  label 'bcftools'
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(annotVcf)
  
  output:
  tuple val(meta), path("*.sorted.vcf"), emit: sortedVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  bcftools sort ${annotVcf} > \$(basename ${annotVcf} .vcf).sorted.vcf  

  """
}


