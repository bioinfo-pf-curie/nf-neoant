/*
 * Add RNA coverage to VCF 
 */

process vcfAddRnaCov {
  tag "${meta.sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(splitSnvVcf),path(splitIndelVcf),path(splitSnvTxt),path(splitIndelTxt)
  
  output:
  tuple val(meta), path("*vt.annot.vcf"), emit: rnaCovVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  vcf-readcount-annotator -s ${meta.sampleName} -t snv -o ${meta.sampleName}.vt.snv.rna.vcf ${splitSnvVcf} ${splitSnvTxt}  RNA 
  vcf-readcount-annotator -s ${meta.sampleName} -t indel -o ${meta.sampleName}.vt.indel.rna.vcf ${splitIndelVcf} ${splitIndelTxt}  RNA 

  grep "^#\\|:RAF" ${meta.sampleName}.vt.snv.rna.vcf  > ${meta.sampleName}.vt.annot.vcf 
  grep ":RAF" ${meta.sampleName}.vt.snv.rna.vcf  >> ${meta.sampleName}.vt.annot.vcf 


  """
}


