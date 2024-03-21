/*
 * Run pvacFuse
 */

process pvacfuseRun {
  tag "${meta.sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(fusionFile), path(hlaI), path(hlaII)
  val algos
  // path iedbPath

  output:
  path("${meta.sampleName}/*/*.fa"), optional: true, emit: pvacFuseFa
  path("${meta.sampleName}/*/*.tsv"), optional: true, emit: pvacFuseTsv

  script:
  """

  hlaIt=\$(cat ${hlaI})
  hlaIIt=\$(cat ${hlaII})
  hla_types_pvac_total=\$(echo \${hlaIt},\${hlaIIt} | sed "s|,\$||g") 


  # Check the number of putative fusions of interest column reading_frame not equal to dot

  fus_str=\$(awk 'NR!=1{print \$16}' ${fusionFile} | sort | uniq)
  
  iedbp="/opt/iedb"

  export TMPDIR="/tmp"

  if [[ \${#fus_str} != 1 ]] ; then 

    pvacfuse run \
          ${fusionFile} \
          ${meta.sampleName} \
          \${hla_types_pvac_total} \
          ${algos} \
          ${meta.sampleName} \
          --class-i-epitope-length 8,9,10,11 \
          --class-ii-epitope-length 12,13,14,15,16,17,18 \
          --top-score-metric lowest \
          --iedb-install-directory \${iedbp} \
          --n-threads ${task.cpus} \
          --read-support 5 \
          --expn-val 0.1 \
          --downstream-sequence-length full \
          --binding-threshold 500 \
          --net-chop-method cterm \
          --netmhc-stab \
          --net-chop-threshold 0.5 
  fi 
          
  """
}


