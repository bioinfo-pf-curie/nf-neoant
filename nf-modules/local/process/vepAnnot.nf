/*
 * VEP vcf annotation
 */

process vepAnnot {
  tag "${sampleName}"
  label 'vep'
  label "medCpu"
  label "medMem"


  input:
  tuple val(sampleName), path(vcf)
  path vep_dir_cache
  path fasta_sib
  path vep_plugin_repo

  output:
  path("*vep.vcf"), emit: vepVcf
  path("versions.txt"), emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  export PERL5LIB=${vep_plugin_repo}

  echo "vep "\$(vep --help 2>&1) > versions.txt

  vep --input_file ${vcf} \
    --output_file ${sampleName}.vep.vcf \
    --offline \
    --cache \
    --dir_cache ${vep_dir_cache} \
    --format vcf \
    --vcf --symbol --terms SO \
    --tsl --force_overwrite \
    --hgvs \
    --fasta ${fasta_sib} \
    --plugin Wildtype --plugin Frameshift --plugin Downstream \
    --pick \
    --transcript_version

  """
}
