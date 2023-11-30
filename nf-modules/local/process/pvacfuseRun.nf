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
  val hlaI
  val hlaII
  val algos
  path iedbPath

  output:
  path("*vt.annot.vcf"), emit: rnaCovVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  hla_types_pvac_total=\$(echo \${hlaI},\${hlaII} | sed "s|,\$||g") 


  pvacfuse run \
        ${fusionFile} \
        ${sampleName} \
        ${hla_types_pvac_total} \
        ${algos} \
        ${sampleName} \
        --class-i-epitope-length 8,9,10,11 \
        --class-ii-epitope-length 12,13,14,15,16,17,18 \
        --top-score-metric lowest \
        --iedb-install-directory ${iedb_path} \
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


