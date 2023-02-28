process YML_CREATION_SPADES {
//    tag "$meta.id"

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(meta), path(pairs), path(singletons)

    output:
    tuple val(meta), path("${prefix}.yaml"), emit: yaml
    path "versions.yml", emit: versions

    script: // This script creates a yml file to be used by SPADES
    prefix = task.ext.prefix ?: "${meta.id}"
    def pairs_list = pairs.join(' ')
    def singletons_list = singletons.join(' ')
    """
    #!/usr/bin/env bash
    echo "bash set"

    r1=''
    r2=''
    sgl=''
    let counter=0
    echo "main variables set"

    for i in ${pairs_list}; do
        if [[ \${counter} == 0 ]]; then
            r1+="\\\"\${i}\\\", "
            let counter+=1
            echo "r1: \${r1}"
        elif [[ \${counter} == 1 ]]; then
            r2+="\\\"\${i}\\\", "
            let counter=0
            echo "r2: \${r2}"
        fi
    done

    for i in ${singletons_list}; do
        sgl+="\\\"\${i}\\\", "
    done
    echo "sgl: \${sgl}"

    echo -e "[{\norientation: \"fr\",\ntype: \"paired-end\",\nright reads: [\${r1%, }],\nleft reads: [\${r2%, }],\nsingle reads: [\${sgl%, }]\n}\n]" > ${prefix}.yaml
    echo "yml done"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(echo \$(bash --version 2>&1 | sed -e 's#.* version##g') | sed 's# .*##g')
    END_VERSIONS
    """
}
