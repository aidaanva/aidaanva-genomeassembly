//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:'\t' )
        .map { create_fastq_channel(it) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample_id
    meta.lib_id     = row.library_id
    meta.single_end = row.pairment == "paired" ? false : true
    meta.treatment = row.damage_treatment

    // add path(s) of the fastq file(s) to the meta map
    def fastq_meta = []
    if (!file(row.r1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.r1}"
    }
    if (meta.single_end) {
        fastq_meta = [ meta, [ file(row.r1) ] ]
    } else {
        if (!file(row.r2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.r2}"
        }
        fastq_meta = [ meta, [ file(row.r1), file(row.r2) ] ]
    }
    return fastq_meta
}
