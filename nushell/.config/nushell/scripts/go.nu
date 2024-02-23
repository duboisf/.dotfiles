export def "from go duration" [] {
    let duration = $in
    use std log
    $duration | split chars
    | reduce --fold {digits: "", pending: "", parts: []} {|x, cumul|
        if $x =~ '\d' {
            $cumul | update digits {$in + $x}
        } else {
            if ($cumul.pending | str length) > 0 {
                log debug $"pending: ($cumul.pending), digits: ($cumul.digits), x: ($x)"
                match $x {
                    "s" => ($cumul | update parts {$in | append ($cumul.digits + $cumul.pending + "s")} | update digits "" | update pending "")
                    _ => (error make {
                        msg: "Invalid duration"
                        label: {
                            text: $"Invalid duration unit: ($x), cumul: ($cumul)",
                        }
                    })
                }
            } else {
                match $x {
                    "s"|"m"|"h" => {
                        let convertedUnit = match $x {
                            "s" => "sec"
                            "m" => "min"
                            "h" => "hr"
                        }
                        $cumul | update parts {$in | append ($cumul.digits + $convertedUnit)} | update digits ""
                    }
                    "n"|"u"|"m" => ($cumul | update pending $x)
                    "µ" => ($cumul | update pending "u")
                    _ => (error make {
                        msg: "Invalid duration unit"
                        label: {
                            text: $"Invalid duration unit: ($x), cumul: ($cumul)",
                        }
                    })
                }
            }
        }
    }
    | get parts
    | str join " "
    | into duration
}
