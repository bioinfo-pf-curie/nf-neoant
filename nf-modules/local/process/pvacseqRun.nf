/*
 * Run pvacseq
 */

process pvacseqRun {
  tag "${meta.sampleName}"
  label 'pvacseq'
  // label "minCpu"
  // label "lowMem"
  label "highCpu"
  label "medMem"

  input:
  tuple val(meta), path(rnaCovVcf), path(hlaI), path(hlaII) // Channel sampleName, annotVcf , hlaIfile, hlaIIfile
  val algos
  val minVafDna
  val minVafRna
  val minVafNormal
  path iedbPath

  output:
  tuple val(meta), path("*hlatypes.txt"), emit: hlaAll
  tuple val(meta), path("${meta.sampleName}/*/*.fa"), emit: pvacSeqFa
  tuple val(meta), path("${meta.sampleName}/*/*.tsv"), emit: pvacSeqTsv
  tuple val(meta), path("${meta.sampleName}/*/*.json"), emit: pvacSeqJson

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  hlaIt=\$(cat ${hlaI})
  hlaIIt=\$(cat ${hlaII})
  hla_types_pvac_total=\$(echo \${hlaIt},\${hlaIIt} | sed "s|,\$||g") 

  echo \${hla_types_pvac_total} > ${meta.sampleName}_hlatypes.txt

  normalId=\$(grep "normal_sample"  ${rnaCovVcf} | cut -f2 -d"=")

  pvacseq run \
            ${rnaCovVcf} \
            ${meta.sampleName} \
            \${hla_types_pvac_total} \
            ${algos} \
            ${meta.sampleName} \
            --n-threads ${task.cpus} \
            --class-i-epitope-length 8,9,10,11 \
            --class-ii-epitope-length 12,13,14,15,16,17,18 \
            --tdna-vaf ${minVafDna} \
            --trna-vaf ${minVafRna} \
            --top-score-metric lowest \
            --downstream-sequence-length full \
            --keep-tmp-files \
            --fasta-size 200 \
            --normal-sample-name \${normalId} \
            --binding-threshold 500 \
            --expn-val 1.0 \
            --maximum-transcript-support-level 1 \
            --minimum-fold-change 0.0 \
            --normal-cov 10 \
            --tdna-cov 10 \
            --trna-cov 10 \
            --normal-vaf ${minVafNormal} \
            --iedb-install-directory ${iedbPath} \
            --iedb-retries 5 \
            --allele-specific-anchors \
            --anchor-contribution-threshold 0.8 \
            --aggregate-inclusion-binding-threshold 5000 \
            --net-chop-method cterm \
            --netmhc-stab \
            --net-chop-threshold 0.5

  """
}


