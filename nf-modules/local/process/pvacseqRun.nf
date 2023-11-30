/*
 * Run pvacseq
 */

process pvacseqRun {
  tag "${sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"

  input:
  val sampleName
  val normalName
  path rnaCovVcf
  val hlaI
  val hlaII
  val algos
  val minVafDna
  val minVafRna
  val minVafNormal
  path iedbPath

  output:
  path("*test.txt"), emit: test

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  hla_types_pvac_total=\$(echo \${hlaI},\${hlaII} | sed "s|,\$||g") 

  echo \${hla_types_pvac_total} > test.txt



  """
}


