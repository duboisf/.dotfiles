def "nu-complete har files" [] {
  glob "**/*.har" | each { path relative-to (pwd) }
}

# Parse a HAR file into a table of HTTP requests
export def main [file: path@"nu-complete har files"] {
  open $file | from json | get log.entries | each { |r|
    let parsed = ($r.request.url | url parse)
    {
      method: $r.request.method
      host: $parsed.host
      path: $parsed.path
      status: (if $r.response.status >= 400 {
        $"(ansi red)($r.response.status)(ansi reset)"
      } else if $r.response.status >= 300 {
        $"(ansi yellow)($r.response.status)(ansi reset)"
      } else {
        $"(ansi green)($r.response.status)(ansi reset)"
      })
      size: ($r.response.content.size? | default 0 | into filesize)
      wait: $r.timings.wait
    }
  }
}
