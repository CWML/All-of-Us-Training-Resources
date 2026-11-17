version 1.0

# PLINK 2 allele frequencies of the common variants (--maf 0.01 --freq) on one chromosome.
# Used in the Running Workflows class (Optional Extras), and to test running a WDL
# from a Git repository on the Workbench's Workflows tab.
# Inputs: the .bed, .bim, and .fam files (gs:// paths), and a PLINK 2 image from the
# All of Us mirror, e.g.
# us-central1-docker.pkg.dev/all-of-us-rw-prod/aou-rw-gar-remote-repo-docker-prod/biocontainer/plink2:alpha2.3_jan2020

workflow plink_freq {
  input {
    File bed
    File bim
    File fam
    String docker_image
  }
  call plink_check { input: bed = bed, bim = bim, fam = fam, docker_image = docker_image }
  output {
    File freq = plink_check.freq
  }
}

task plink_check {
  input {
    File bed
    File bim
    File fam
    String docker_image
  }
  command {
    plink2 --bed ~{bed} --bim ~{bim} --fam ~{fam} --maf 0.01 --freq --out chr
  }
  output {
    File freq = "chr.afreq"
  }
  runtime {
    docker: docker_image
    machineType: "n2-standard-2"
    disks: "local-disk 30 SSD"
  }
}
