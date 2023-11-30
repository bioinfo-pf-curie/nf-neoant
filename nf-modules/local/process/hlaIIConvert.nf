/*
 * Convert HLA-LA for MHCII file
 */

process hlaIIConvert {
  tag "${sampleName}"
  // label 'pvacseq'
  label "minCpu"
  label "lowMem"

  input:
  val sampleName
  path hlaIIfile //hla/R1_bestguess_G.txt

  output:
  path("*_mhcII.txt"), emit: hlaII

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  hlala_types=\$(awk '{if(\$9 ==1 && \$NF ==1 &&  \$3 ~ /^D/) print \$3}' ${hlaIIfile} |uniq | sed "s|....\$||g" | awk 'ORS=","{print \$1}' | sed "s|,\$||g")

  echo \${hlala_types} > ${sampleName}_mhcII.txt

  """
}


