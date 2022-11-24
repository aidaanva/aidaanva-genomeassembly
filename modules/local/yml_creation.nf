process YML_CREATION_SPADES {
    tag "$meta.id"

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(meta), path(pairs), path(singletons)

    output:
    tuple val(meta), path("${prefix}.yaml"), emit: yaml
    path "versions.yml", emit: versions

    prefix = task.ext.prefix ?: "${meta.id}"

    script: // This script creates a yml file to be used by SPADES
    """

    """
}
