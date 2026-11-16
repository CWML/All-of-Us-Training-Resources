// PLINK 2 allele frequencies of the common variants (--maf 0.01 --freq), one task per chromosome.
// Used in the Running Workflows class (Optional Extras), and to test running Nextflow
// from a Git repository on the Workbench's Workflows tab.
// outDir: a gs:// folder in your workspace bucket for the results (required).

params.plinkDir = "gs://vwb-aou-datasets-controlled/v9/wgs/short_read/snpindel/clinvar/plink_bed"
params.image    = "us-central1-docker.pkg.dev/all-of-us-rw-prod/aou-rw-gar-remote-repo-docker-prod/biocontainer/plink2:alpha2.3_jan2020"
params.chroms   = "19,20,21,22"
params.outDir   = null

process plink_check {
  container params.image
  cpus 2
  memory "8 GB"
  publishDir params.outDir, mode: "copy"

  input:
  tuple val(chr), path(bed), path(bim), path(fam)

  output:
  path "chr${chr}.afreq"

  script:
  """
  plink2 --bed ${bed} --bim ${bim} --fam ${fam} --maf 0.01 --freq --out chr${chr}
  """
}

workflow {
  if (!params.outDir) error "Set outDir: a gs:// folder in your workspace bucket"
  Channel.of(params.chroms.toString().split(",")).map { it.trim() }
    .map { c -> tuple(c, file("${params.plinkDir}/clinvar.chr${c}.bed"),
                         file("${params.plinkDir}/clinvar.chr${c}.bim"),
                         file("${params.plinkDir}/clinvar.chr${c}.fam")) }
    | plink_check
}
