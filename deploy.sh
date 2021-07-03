#!/bin/bash

usage () {
    echo
    echo "Usage:"
    echo "  $ $0 <helm-command> <namespace>/<chart>/<values> [<extra-arg1=v1,extra-arg2=v2...>]"
    echo
    echo "Options for helm-command includes:"
    echo "  update, lint, diff, upgrade, uninstall"
    echo
    echo "For example:"
    echo "  $ $0 diff monitoring/kube-prom-stack/values/kube-example-com.yaml"
    echo
}

main () {
    cmd=$1
    ns=$(echo $2 | cut -d '/' -f 1)
    chart=$(echo $2 | cut -d '/' -f 2)
    values=$(echo $2 | cut -d '/' -f 3-)
    extra_args=$3

    red=$(tput setaf 1)
    green=$(tput setaf 2)
    norm=$(tput sgr0)

    if [[ -z ${cmd} ]] || [[ -z ${ns} ]] || [[ -z ${chart} ]] || [[ -z ${values} ]]; then
        echo "${red}[ERROR]${norm} missing arguments"
        usage
        exit 2
    fi

    arr=($(echo ${extra_args} | sed 's/,/\n/g'))
    for i in ${arr[@]}; do
        args+="--set $i "
    done

    echo "== Input"
    echo "  namespace: ${green}${ns}${norm}"
    echo "  chart: ${green}${chart}${norm}"
    echo "  values: ${green}${values}${norm}"
    [[ -z ${arr+x} ]] || echo "  extra args: ${green}${arr[@]}${norm}"
    echo

    if [[ -d ${ns} ]]; then
        cd ${ns}
    else
        echo "${red}[ERROR]${norm} namespace ${ns} not found"
        exit 2
    fi

    echo "== Command"
    echo "  Running helm ${red}${cmd}${norm}"
    echo

    case ${cmd} in
        update)
            helm dependency update ${chart}
            ;;
        lint)
            helm lint \
                --values ${chart}/${values} \
                ${chart}
            ;;
        diff)
            helm diff upgrade \
                --install \
                --namespace ${ns} \
                --values ${chart}/${values} \
                ${args} \
                ${chart} ${chart}
            ;;
        upgrade)
            helm upgrade \
                --install \
                --namespace ${ns} \
                --values ${chart}/${values} \
                ${args} \
                ${chart} ${chart}
            ;;
        uninstall)
            helm uninstall \
                --namespace ${ns} \
                ${chart} ${chart}
            ;;
        *)
            echo "${red}[ERROR]${norm} unrecognized helm command"
            exit 2
            ;;
    esac
}

main $@
