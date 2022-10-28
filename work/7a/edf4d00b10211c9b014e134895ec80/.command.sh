#!/bin/bash -euo pipefail
check_samplesheet.py \
    test.samplesheet.tsv \
    samplesheet.valid.csv

cat <<-END_VERSIONS > versions.yml
"AIDAANVA_GENOMEASSEMBLY:GENOMEASSEMBLY:INPUT_CHECK:SAMPLESHEET_CHECK":
    python: $(python --version | sed 's/Python //g')
END_VERSIONS
