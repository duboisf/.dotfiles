use waws/wrapper.nu *

export def "log-groups" []: nothing -> list<string> {
  waws logs describe-log-groups | get logGroupName
}

# Query cloudwatch logs.
# Example:
#
#   let queryId = waws logs query some-flow-log-group ((date now) - 5min) '
#       fields @timestamp, action, srcAddr, srcPort, dstAddr, dstPort
#       | filter ( isIpv4InSubnet(srcAddr, "10.15.0.0/20") or isIpv4InSubnet(srcAddr, "10.15.48.0/20") or isIpv4InSubnet(srcAddr, "10.15.96.0/20")) and isIpv4InSubnet(dstAddr, "10.15.0.0/16")
#   '
#   waws logs results $queryId | save /tmp/query-results.nuon
#   open /tmp/query-results.nuon
#   | update srcPort { into int }
#   | update dstPort { into int }
#   | where dstPort > 8000 and dstPort < 9000
export def query [
  logGroup: string,
  relativeStartTime: duration,
  query: string
]: nothing -> string {
  (^aws logs start-query 
      --log-group-name $logGroup
      --start-time ((date now) - $relativeStartTime | format date "%s")
      --end-time (date now | format date "%s") 
      --query-string $query
    | from json
    | get queryId
  )
}

export def status [queryId?: string]: nothing -> table {
  let res = ^aws logs describe-queries
    | from json
    | get queries
  if ($res | is-empty) {
    print "Query not found"
  } else {
    match $queryId {
      null => $res
      _ => ($res | where queryId == $queryId | first)
    }
  }
}

export def results [queryId?: string]: nothing -> table {
  let id = match $queryId {
    null => (status | get queryId | first)
    _ => $queryId
  }
  ^aws logs get-query-results --query-id $id
  | from json
  | get results
  | each { transpose --as-record --header-row | reject @ptr }
}
