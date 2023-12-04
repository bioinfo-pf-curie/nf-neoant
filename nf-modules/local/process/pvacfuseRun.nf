/*
 * Run pvacFuse
 */

process pvacfuseRun {
  tag "${sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"

  input:
  val sampleName
  path fusionFile //star_arriba.fusions.tsv
  path hlaI
  path hlaII
  val algos
  path iedbPath

  output:
  path("${sampleName}/*/*.fa"), emit: pvacFuseFa
  path("${sampleName}/*/*.tsv"), emit: pvacFuseTsv

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  hlaIt=\$(cat ${hlaI})
  hlaIIt=\$(cat ${hlaII})
  hla_types_pvac_total=\$(echo \${hlaIt},\${hlaIIt} | sed "s|,\$||g") 

  pvacfuse run \
        ${fusionFile} \
        ${sampleName} \
        \${hla_types_pvac_total} \
        ${algos} \
        ${sampleName} \
        --class-i-epitope-length 8,9,10,11 \
        --class-ii-epitope-length 12,13,14,15,16,17,18 \
        --top-score-metric lowest \
        --iedb-install-directory ${iedbPath} \
        --n-threads ${task.cpus} \
        --read-support 5 \
        --expn-val 0.1 \
        --downstream-sequence-length full \
        --binding-threshold 500 \
        --keep-tmp-files \
        --net-chop-method cterm \
        --netmhc-stab \
        --net-chop-threshold 0.5
  """
}


