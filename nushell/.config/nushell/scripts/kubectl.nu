export def --wrapped no [
    ...rest: string        # Extra arguments to pass to kubectl get nodes
] {
    let args = [
        get no
        -L kubernetes.io/arch
        -L karpenter.sh/capacity-type
        -L node.kubernetes.io/instance-type
        -L karpenter.k8s.aws/instance-cpu
        -L karpenter.k8s.aws/instance-memory
        -L dedicated
        -L karpenter.sh/nodepool
        ...$rest
    ]
    ^kubectl ...$args
        | from ssv
        | rename -b {str downcase}
        | update age {str replace 's' 'sec ' | str replace 'd' 'day ' | str replace 'm' 'min ' | str replace 'h' 'hr '}
        | update age {into duration}
}

export def --wrapped "dno" [
    ...rest: string        # Extra arguments to pass to kubectl get nodes
] {
    kubectl get no ...$rest
        | get items
        | where metadata.name !~ fargate
        | rename -c  {metadata: m}
        | select m spec status | reject m.annotations status.images
        | update m.creationTimestamp {into datetime}
        | update status.conditions.lastTransitionTime {into datetime}
}

export def --wrapped "kubectl get" [...rest] {
    let input = $in
    if ($rest | any {$in in [--help -h]}) {
        ^kubectl get ...$rest
    } else { 
        ^kubectl get ...$rest -o json | from json
    }
}

# export alias "k get" = kubectl get

export def --wrapped po [
    ...rest: string          # Extra arguments to pass to kubectl get pods
] {
    let args = [get po -o wide ...$rest] | compact
    kubectl ...$args
        | complete
        | get stdout
        | from ssv
        | rename -b {str downcase}
        | update age {str replace 's' 'sec ' | str replace 'd' 'day ' | str replace 'm' 'min ' | str replace 'h' 'hr '}
        | update age {into duration}
}

export def "kube contexts" [] {
    kubectl config view -o json
    | from json
    | get contexts
    | flatten
    | where name != none
}
