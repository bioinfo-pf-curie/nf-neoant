/*
 * Sort VCF 
 * Filter on DP, AF, RDP, RAF somatic, and DP & AF germline  
 */

process sortVcf {
  tag "${meta.sampleName}"
  label 'bcftools'
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(annotVcf)
  
  output:
  tuple val(meta), path("*.sorted.filt.vcf.gz"), emit: sortedVcf

  script:
  def args = task.ext.args ?: ''
  def id = 0

  """

  if [ ${meta.sampleName} == \$(zgrep "#CHROM" ${annotVcf} | cut -f10) ] ; then id=0; else id=1; fi

  declare prefix=\$(basename ${annotVcf} .vcf)

  bcftools sort -Oz ${annotVcf} > \${prefix}.sorted.vcf.gz  

  bcftools view -Oz -i '${args}' \${prefix}.sorted.vcf.gz --threads ${task.cpus} -o \${prefix}.sorted.filt.vcf.gz

  tabix  \${prefix}.sorted.filt.vcf.gz


  """
}


