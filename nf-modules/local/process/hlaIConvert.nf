/*
 * Convert Optitype for MHCI file
 */

process hlaIConvert {
  tag "${sampleName}"
  // label 'pvacseq'
  label "minCpu"
  label "lowMem"

  input:
  val sampleName
  path hlaIfile

  output:
  path("*_mhcI.txt"), emit: hlaI

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  max_hla=\$(awk 'NR==1{for(i=0;i<=NF;i++){if(\$i == "Reads") print i}}' ${hlaIfile})
  hla_types=\$(awk -v hla=\${max_hla} '{ORS=","}NR==2{for(i=2;i<=hla;i++){print "HLA-"\$i}}' ${hlaIfile} | sed "s|,\$||g")

  echo \${hla_types} > ${sampleName}_mhcI.txt

  """
}


