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
        r1=''
        r2=''
        sgl=''
        let counter=0
        for i in ${pairs_list}; do
            if [[ \${counter} == 0 ]]; then
                r1+="\\\"\${i}\\\", "
                let counter+=1
            elif [[ \${counter} == 1 ]]; then
                r2+="\\\"\${i}\\\", "
                let counter=0
            fi
        done

        for i in ${singletons_list}; do
            sgl+="\\\"\${i}\\\", "
        done

        echo -e "[{\n\torientation: \"fr\",\n\ttype: \"paired-end\",\n\tright reads: [\${r1%, }],\n\tleft reads: [\${r2%, }],\n\tsingle reads: [\${sgl%, }]\n\t}\n]" > ${prefix}.yaml


        # ${pairs_list}
        # ${pairs[0]} ${singletons[0]}
        # ${pairs[1]} ${singletons[1]}
    """
}
