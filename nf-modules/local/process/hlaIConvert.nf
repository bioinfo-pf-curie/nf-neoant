/*
 * Convert Optitype for MHCI file
 */

process hlaIConvert {
  tag "${meta.sampleName}"
  label "minCpu"
  label "lowMem"

  input:
  tuple val(meta), path(hlaIfile)

  output:
  tuple val(meta), path("*_mhcI.txt"), emit: hlaI

  script:
  """

  max_hla=\$(awk 'NR==1{for(i=0;i<=NF;i++){if(\$i == "Reads") print i}}' ${hlaIfile})
  hla_types=\$(awk -v hla=\${max_hla} '{ORS=","}NR==2{for(i=2;i<=hla;i++){print "HLA-"\$i}}' ${hlaIfile} | sed "s|,\$||g")

  echo \${hla_types} > ${meta.sampleName}_mhcI.txt

  """
}


