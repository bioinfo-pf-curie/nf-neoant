/*
 * VEP vcf annotation
 */

process vepAnnot {
  tag "${meta.sampleName}"
  label 'vep'
  label "medCpu"
  label "medMem"


  input:
  tuple val(meta), path(vcf)
  path vep_dir_cache
  path fasta
  path vep_plugin_repo

  output:
  tuple val(meta), path("*vep.vcf"), emit: vepVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  
  
  export PERL5LIB=${vep_plugin_repo}

  vep --input_file ${vcf} \
    --output_file ${meta.sampleName}.vep.vcf \
    --offline \
    --cache \
    --dir_cache ${vep_dir_cache} \
    --format vcf \
    --vcf --symbol --terms SO \
    --tsl --force_overwrite \
    --hgvs \
    --fasta ${fasta} \
    --plugin Wildtype --plugin Frameshift --plugin Downstream \
    --pick \
    --transcript_version

  """
}
