/*
 * mixcr analysis
 */

process mixcr {
  tag "${meta.sampleName}"
  label "mixcr"
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(fastqRnaR1), path(fastqRnaR2) 
  val species // hsa
  val mi_license

  output:
  tuple val(meta), path("${meta.sampleName}/*clns"), path("${meta.sampleName}/${meta.sampleName}.chainUsage.pdf"), emit: mixcrOut

  script:
  def args = task.ext.args ?: ''
   
  """

    export MI_LICENSE_FILE="${mi_license}"

    mixcr analyze rna-seq \
        --threads ${task.cpus} \
        --species ${species} \
        ${fastqRnaR1} ${fastqRnaR2} \
        ${meta.sampleName}/${meta.sampleName}

    mixcr exportQc chainUsage ${meta.sampleName}/*.clns  ${meta.sampleName}/${meta.sampleName}.chainUsage.pdf
  
  """
}





