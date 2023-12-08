/*
 * Convert HLA-LA for MHCII file
 */

process hlaIIConvert {
  tag "${meta.sampleName}"
  label "minCpu"
  label "lowMem"

  input:
  tuple val(meta), path(hlaIIfile) //hla/R1_bestguess_G.txt

  output:
  tuple val(meta), path("*_mhcII.txt"), emit: hlaII

  script:
  """

  hlala_types=\$(awk '{if(\$9 ==1 && \$NF ==1 &&  \$3 ~ /^D/) print \$3}' ${hlaIIfile} |uniq | sed "s|....\$||g" | awk 'ORS=","{print \$1}' | sed "s|,\$||g")

  echo \${hlala_types} > ${meta.sampleName}_mhcII.txt

  """
}


