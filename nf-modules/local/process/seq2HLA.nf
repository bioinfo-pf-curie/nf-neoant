/*
 * Create HLAI & HLAII with seq2hla from RNAseq fastq files
 */

process seq2HLA {
  tag "${meta.sampleName}"
  label 'seq2hla'
  label "highCpu"
  label "highMem"

  input:
  tuple val(meta), path(fastqRnaR1), path(fastqRnaR2)

  output:
  tuple val(meta), path("*_mhcI.txt"), path("*_mhcII.txt"), emit: hla

  script:
  """

  seq2HLA  -1 ${fastqRnaR1} -2 ${fastqRnaR2} -r ${meta.sampleName} -p ${task.cpus}

  awk '{ORS="," ; OFS=","}NR!=1{print "HLA-"\$2,"HLA-"\$4}' ${meta.sampleName}-ClassI-class.HLAgenotype4digits | sed "s|'||g" | sed "s|,\$||g" > ${meta.sampleName}_mhcI.txt

  awk '{ORS=","}NR!=1{print \$2}' ${meta.sampleName}-ClassII.HLAgenotype4digits | sed "s|'||g" | sed "s|,\$||g" > ${meta.sampleName}_mhcII.txt

  """
}


