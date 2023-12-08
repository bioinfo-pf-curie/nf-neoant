#!/usr/bin/env nextflow

/*
Copyright Institut Curie 2019-2022
This software is a computer program whose purpose is to analyze high-throughput sequencing data.
You can use, modify and/ or redistribute the software under the terms of license (see the LICENSE file for more details).
The software is distributed in the hope that it will be useful, but "AS IS" WITHOUT ANY WARRANTY OF ANY KIND.
Users are therefore encouraged to test the software's suitability as regards their requirements in conditions enabling the security of their systems and/or data. 
The fact that you are presently reading this means that you have had knowledge of the license and that you accept its terms.
*/

/*
========================================================================================
                         DSL2 Template
========================================================================================
Analysis Pipeline DSL2 template.
https://patorjk.com/software/taag/
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

// Initialize lintedParams and paramsWithUsage
NFTools.welcome(workflow, params)

// Use lintedParams as default params object
paramsWithUsage = NFTools.readParamsFromJsonSettings("${projectDir}/parameters.settings.json")
params.putAll(NFTools.lint(params, paramsWithUsage))

// Run name
customRunName = NFTools.checkRunName(workflow.runName, params.name)

// Custom functions/variables
mqcReport = []
//include {checkAlignmentPercent} from './lib/functions'

/*
===================================
  SET UP CONFIGURATION VARIABLES
===================================
*/

// Genome-based variables
if (!params.genome){
  exit 1, "No genome provided. The --genome option is mandatory"
}

if (params.genomes && params.genome && !params.genomes.containsKey(params.genome)) {
  exit 1, "The provided genome '${params.genome}' is not available in the genomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
}

// Stage config files
// multiqcConfigCh = Channel.fromPath(params.multiqcConfig)
outputDocsCh = Channel.fromPath("$projectDir/docs/output.md")
outputDocsImagesCh = file("$projectDir/docs/images/", checkIfExists: true)


/*
===========================
   SUMMARY
===========================
*/

summary = [
  'Pipeline Release': workflow.revision ?: null,
  'Run Name': customRunName,
  'Inputs' : params.samplePlan ?: null,
  'Genome' : params.genome,
  'Max Resources': "${params.maxMemory} memory, ${params.maxCpus} cpus, ${params.maxTime} time per job",
  'Container': workflow.containerEngine && workflow.container ? "${workflow.containerEngine} - ${workflow.container}" : null,
  'Profile' : workflow.profile,
  'OutDir' : params.outDir,
  'WorkDir': workflow.workDir
].findAll{ it.value != null }

workflowSummaryCh = NFTools.summarize(summary, workflow, params)

/*
==============================
  LOAD INPUT DATA
==============================
*/

// Load raw data
chRawData = NFTools.getInputData(params.samplePlan)
//return [sampleId, sampleName , normalName, fastqDnaR1, fastqDnaR2, sampleDnaBam, sampleDnaBamIndex, vcf, fastqRnaR1, fastqRnaR2, sampleRnaBam, sampleRnaBamIndex, hlaI] 
//return [meta, fastqDnaR1, fastqDnaR2, sampleDnaBam, sampleDnaBamIndex, vcf, fastqRnaR1, fastqRnaR2, sampleRnaBam, sampleRnaBamIndex, hlaI] 

params.transcriptsFasta  = NFTools.getGenomeAttribute(params, 'transcriptsFasta')
params.gtf = NFTools.getGenomeAttribute(params, 'gtf')
params.gtf_sib = NFTools.getGenomeAttribute(params, 'gtf_sib')
params.gff_sib = NFTools.getGenomeAttribute(params, 'gff_sib')
params.star = NFTools.getGenomeAttribute(params, 'star')
params.star_sib = NFTools.getGenomeAttribute(params, 'star_sib')
params.fasta = NFTools.getGenomeAttribute(params, 'fasta')
params.fastaFai = NFTools.getGenomeAttribute(params, 'fastaFai')
params.fastaDict = NFTools.getGenomeAttribute(params, 'fastaDict')
params.fasta_sib = NFTools.getGenomeAttribute(params, 'fasta_sib')
params.fastaFai_sib = NFTools.getGenomeAttribute(params, 'fastaFai_sib')

/*
==========================
 BUILD CHANNELS
==========================
*/

chStarIndex         = params.star      ? Channel.fromPath(params.star, checkIfExists: true).collect()       : Channel.empty()
chStarSibIndex      = params.star_sib      ? Channel.fromPath(params.star_sib, checkIfExists: true).collect()       : Channel.empty()
chGff               = params.gff_sib      ? Channel.fromPath(params.gff_sib, checkIfExists: true).collect()       : Channel.empty()
chTranscriptsFasta  = params.transcriptsFasta      ? Channel.fromPath(params.transcriptsFasta, checkIfExists: true).collect()       : Channel.empty()
chGtf               = params.gtf                   ? Channel.fromPath(params.gtf, checkIfExists: true).collect()                    : Channel.empty()
chGtfSib            = params.gtf_sib                   ? Channel.fromPath(params.gtf_sib, checkIfExists: true).collect()                    : Channel.empty()

chFastaSib          = params.fasta_sib      ? Channel.fromPath(params.fasta_sib, checkIfExists: true).collect()       : Channel.empty()
chFastaSibFai       = params.fastaFai_sib      ? Channel.fromPath(params.fastaFai_sib, checkIfExists: true).collect()       : Channel.empty()

chFasta             = params.fasta      ? Channel.fromPath(params.fasta, checkIfExists: true).collect()       : Channel.empty()
chFastaFai          = params.fastaFai      ? Channel.fromPath(params.fastaFai, checkIfExists: true).collect()       : Channel.empty()
chFastaDict         = params.fastaDict      ? Channel.fromPath(params.fastaDict, checkIfExists: true).collect()       : Channel.empty()
chVepCache          = params.vepDirCache      ? Channel.fromPath(params.vepDirCache, checkIfExists: true).collect()       : Channel.empty()
chVepPlugin         = params.vepPluginRepo      ? Channel.fromPath(params.vepPluginRepo, checkIfExists: true).collect()       : Channel.empty()

chGraphDir          = params.graphDir      ? Channel.fromPath(params.graphDir, checkIfExists: true).collect()       : Channel.empty()
chGraphName         = params.graphName  //    ? Channel.Value(params.graphName, checkIfExists: true).collect()       : Channel.empty()


chBlackList         = params.blackList      ? Channel.fromPath(params.blackList, checkIfExists: true).collect()       : Channel.empty()
chProteinGff        = params.proteinGff      ? Channel.fromPath(params.proteinGff, checkIfExists: true).collect()       : Channel.empty()
chLayout            = params.layout

chAlgos             = params.algos     
chMinVafDna         = params.min_vaf_dna    
chMinVafRna         = params.min_vaf_rna     
chMinVafNormal      = params.min_vaf_normal     
chIedbPath          = params.iedb_path      ? Channel.fromPath(params.iedb_path, checkIfExists: true).collect()       : Channel.empty()

chVtTools           = params.vtTools      ? Channel.fromPath(params.vtTools, checkIfExists: true).collect()       : Channel.empty()

chSpecies           = params.species
chMiLicense         = params.miLicense    

/*
==================================
           INCLUDE
==================================
*/ 

// Workflows
include { salmonQuantFromBamFlow } from './nf-modules/local/subworkflow/salmonQuantFromBamFlow'
include { vcfAnnotFlow } from './nf-modules/local/subworkflow/vcfAnnotFlow'
include { pVacseqFlow } from './nf-modules/local/subworkflow/pVacseqFlow'
include { pVacFuseFlow } from './nf-modules/local/subworkflow/pVacFuseFlow'

// Processes
include { getSoftwareVersions } from './nf-modules/common/process/getSoftwareVersions'
include { outputDocumentation } from './nf-modules/common/process/outputDocumentation'
include { mixcr } from './nf-modules/local/process/mixcr'

/*
=====================================
            WORKFLOW 
=====================================
*/

workflow {

  main:

    chRawData
      .map{ it ->
        def meta = [sampleName:it[0].sampleName] //[meta], fastqRnaR1, fastqRnaR2
        return [meta, it[6], it[7] ]
      }.set{ chPairRnaFastq }

    //*******************************************
    // Salmon transcript quantification

    salmonQuantFromBamFlow (
          chPairRnaFastq,
          chTranscriptsFasta,
          chGtf, 
          chStarIndex,
          chGff
        )

    chRawData
      .map{ it ->
        def meta = [sampleName:it[0].sampleName ] //[meta], vcf
        return [meta, it[5], it[8], it[9] ]
      }.set{ chDnaVcfRnaBam }

 
    //*******************************************
    // Vcf annotation

    vcfAnnotFlow (
          chDnaVcfRnaBam,
          chVepCache,
          chFasta,
          chFastaFai,
          chFastaDict,
          chVepPlugin,
          salmonQuantFromBamFlow.out.tpm,
          chVtTools
        )

    //*******************************************
    // pVacseq

    pVacseqFlow (
          chRawData,
          chGraphDir,
          chGraphName,
          vcfAnnotFlow.out.annotVcf,
          chAlgos,
          chMinVafDna,
          chMinVafRna,
          chMinVafNormal,
          chIedbPath 
        )

    //*******************************************
    // pVacFuse

    chRawData
      .map{ it ->
        def meta = [sampleName:it[0].sampleName ]
        return [meta, it[8], it[9] ]
      }.set{ chRnaBam }

    chHlatm =  pVacseqFlow.out.hlaIfile.join(pVacseqFlow.out.hlaIIfile) // sampleName, hlaIfile, hlaIIfile

    pVacFuseFlow (
          chRnaBam, // sampleName, RnaBam, RnaBamIndex
          chStarSibIndex,
          chGtfSib,
          chFastaSib,
          chFastaSibFai,
          chLayout,
          chBlackList,
          chProteinGff,
          chHlatm, // sampleName, hlaIfile, hlaIIfile
          chAlgos,
          chIedbPath
        )

    //*******************************************
    // mixcr

      mixcr(
        chPairRnaFastq, // sampleName, fastqRnaR1, fastqRnaR2
        chSpecies,
        chMiLicense
        )

}
