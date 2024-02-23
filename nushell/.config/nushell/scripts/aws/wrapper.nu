export def --wrapped aws [...rest]: nothing -> list<any> {
    if $rest != [] and ($rest | last) == "help" {
        ^aws ...$rest
    } else {
        let output = ^aws --output json ...$rest | complete
        if $output.exit_code == 0 {
            $output.stdout | from json | get-first
        } else {
            $output
        }
    }
}

export def "get-first" []: record -> any {
    let input = $in
    try {
        let cellPath = $input | describe | parse --regex 'record\<(.+?):' | get capture0.0
        $input | get $cellPath
    } catch {
        $input
    }
}
