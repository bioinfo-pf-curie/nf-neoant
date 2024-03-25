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
  val species 
  val mi_license

  output:
  tuple val(meta), path("${meta.sampleName}/*clns"), path("${meta.sampleName}/${meta.sampleName}.chainUsage.pdf"), emit: mixcrOut
  path("${meta.sampleName}/*.align.report.txt"), emit: mixcrTxtOut
  path("${meta.sampleName}/*.tsv"), emit: mixcrTsvOut

  """

    export MI_LICENSE_FILE="${mi_license}"

    export TMPDIR="/tmp"

    mixcr analyze rna-seq \
        --threads ${task.cpus} \
        --species ${species} \
        ${fastqRnaR1} ${fastqRnaR2} \
        ${meta.sampleName}/${meta.sampleName}

    mixcr exportQc chainUsage ${meta.sampleName}/*.clns  ${meta.sampleName}/${meta.sampleName}.chainUsage.pdf
  
  """
}





