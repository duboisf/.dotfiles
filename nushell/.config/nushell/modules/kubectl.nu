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
}

# export def --wrapped "dno" [
#     ...rest: string        # Extra arguments to pass to kubectl get nodes
# ] {
#     kubectl get no ...$rest
#         | get items
#         | where metadata.name !~ fargate
#         | rename -c  {metadata: m}
#         | select m spec status | reject m.annotations status.images
#         | update m.creationTimestamp {into datetime}
#         | update status.conditions.lastTransitionTime {into datetime}
# }

# export def --wrapped "kg" [...rest] {
#     ^kubectl get ...$rest -o json | from json | get items
# }

# export alias "k get" = kubectl get

export def --wrapped po [
    ...rest: string          # Extra arguments to pass to kubectl get pods
] {
    let args = [get po ...$rest]
    ^kubectl ...$args
    # kubectl ...$args
    #     | complete
    #     | get stdout
    #     | from ssv
    #     | rename -b {str downcase}
    #     | update age {str replace 's' 'sec ' | str replace 'd' 'day ' | str replace 'm' 'min ' | str replace 'h' 'hr '}
    #     | update age {into duration}
}

export def "kctxs" [] {
    ^kubectl config view -o json
    | from json
    | get contexts
    | flatten
    | where name != none
}

# Get kubernetes pods
export def poj []: nothing -> table<name: string, ready: string, status: string, age: datetime> {
    kubectl get pods -o json | from json | get items
        | each { |in| {
            name: $in.metadata.name,
            ready: ($in.status.containerStatuses
                | do {
                    let total = ($in | length)
                    let ready = ($in | where state.running? != null | length)
                    $"($ready)/($total)"
                }
            ),
            status: $in.status.phase,
            age: ($in.metadata.creationTimestamp | into datetime)
        }}
}
