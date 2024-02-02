/*
 * Run pvacseq
 */

process pvacseqRun {
  tag "${meta.sampleName}"
  label 'pvacseq'
  label "highCpu"
  label "medMem"

  input:
  tuple val(meta), path(rnaCovVcf), path(hlaI), path(hlaII) // Channel sampleName, annotVcf , hlaIfile, hlaIIfile
  val algos
  val minVafDna
  val minVafRna
  val minVafNormal
  val minCovDna
  val minCovRna
  path iedbPath

  output:
  // tuple val(meta), path("*hlatypes.txt"), emit: hlaAll
  tuple val(meta), path("${meta.sampleName}/*/*.fa"), optional: true, emit: pvacSeqFa
  tuple val(meta), path("${meta.sampleName}/*/*.tsv"), optional: true, emit: pvacSeqTsv
  tuple val(meta), path("${meta.sampleName}/*/*.json"), optional: true, emit: pvacSeqJson

  script:
  def args = task.ext.args ?: ''

  """
  hlaIt=\$(cat ${hlaI})
  hlaIIt=\$(cat ${hlaII})
  hla_types_pvac_total=\$(echo \${hlaIt},\${hlaIIt} | sed "s|,\$||g") 

  mkdir -p ${meta.sampleName}

  echo \${hla_types_pvac_total} > ${meta.sampleName}/${meta.sampleName}_hlatypes.txt

  normalId=\$(zgrep "normal_sample"  ${rnaCovVcf} | cut -f2 -d"=")

  pvacseq run \
            ${rnaCovVcf} \
            ${meta.sampleName} \
            \${hla_types_pvac_total} \
            ${algos} \
            ${meta.sampleName} \
            --n-threads ${task.cpus} \
            --tdna-vaf ${minVafDna} \
            --trna-vaf ${minVafRna} \
            --normal-sample-name \${normalId} \
            --normal-vaf ${minVafNormal} \
            --iedb-install-directory ${iedbPath} \
            --tdna-cov ${minCovDna} \
            --trna-cov ${minCovRna} \
            ${args}


  """
}


