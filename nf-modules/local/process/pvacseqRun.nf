/*
 * Run pvacseq
 */

process pvacseqRun {
  tag "${sampleName}"
  label 'pvacseq'
  label "highCpu"
  label "medMem"

  input:
  val sampleName
  val normalName
  path rnaCovVcf
  path hlaI
  path hlaII
  val algos
  val minVafDna
  val minVafRna
  val minVafNormal
  path iedbPath

  output:
  path("*hlatypes.txt"), emit: hlaAll
  path("${sampleName}/*/*.fa"), emit: pvacSeqFa
  path("${sampleName}/*/*.tsv"), emit: pvacSeqTsv

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  hlaIt=\$(cat ${hlaI})
  hlaIIt=\$(cat ${hlaII})
  hla_types_pvac_total=\$(echo \${hlaIt},\${hlaIIt} | sed "s|,\$||g") 

  echo \${hla_types_pvac_total} > ${sampleName}_hlatypes.txt

  pvacseq run \
            ${rnaCovVcf} \
            ${sampleName} \
            \${hla_types_pvac_total} \
            ${algos} \
            ${sampleName} \
            --n-threads ${task.cpus} \
            --class-i-epitope-length 8,9,10,11 \
            --class-ii-epitope-length 12,13,14,15,16,17,18 \
            --tdna-vaf ${minVafDna} \
            --trna-vaf ${minVafRna} \
            --top-score-metric lowest \
            --downstream-sequence-length full \
            --keep-tmp-files \
            --fasta-size 200 \
            --normal-sample-name ${normalName} \
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


