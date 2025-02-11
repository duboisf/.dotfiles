
# Query vpc flow logs.
# Note: to use this helper, the flow logs must be configured with all standard
# fields, not the default format.
export def query-vpc-flow-logs [logGroup: string, relativeStartTime: duration, filter: string]: nothing -> table {
  let queryId = (^aws logs start-query 
    --log-group-name $logGroup
    --start-time ((date now) - $relativeStartTime | format date "%s")
    --end-time (date now | format date "%s") 
    --query-string $"
      fields @timestamp, action, srcAddr, pktSrcAddr, srcPort, pktSrcAwsService, dstAddr, pktDstAddr, dstPort, pktDstAwsService, flowDirection, tcpFlags, trafficPath, bytes, start, end, instanceId, interfaceId, packets, protocol, rejectReason, sublocationId, sublocationType, subnetId, vpcId
      | filter ($filter)")
  | from json
  | get queryId

  print "Getting network interfaces..."
  let enis = ^aws --output=json ec2 describe-network-interfaces | from json
  | get NetworkInterfaces
  print "Getting subnets..."
  let subnets = ^aws --output=json ec2 describe-subnets --output json | from json
  | get Subnets
  | default 'N/A' Tags
  | insert Name { |row| try { $row.Tags | where Key == Name | get Value | first } catch { "❎" } }
  print "Getting kubernetes pods..."
  let pods = kubectl get pods -o wide -A | from ssv

  mut i = 0
  loop {
     let status = ^aws --output json logs describe-queries
      | from json
      | get queries
      | where queryId == $queryId
      | first
      | get status
      match $status {
      "Complete" => {
          print "Query is complete. Fetching and transforming results..."
          break
      }
      _ => {
        $i = $i + 1
        if $i >= 20 { break }
        print $"Waiting for logs to be ready, status is ($status)..."
        sleep 3sec
      }
    }
  }

  let descriptionFromIp = { |ip|
      try {
        let pod = $pods
        | where IP == $ip
        | first
        $"EKS pod ($pod.NAMESPACE)/($pod.NAME)"
      } catch {
        try {
          let desc = $enis
          | where PrivateIpAddress == $ip
          | first
          | get Description
          if $desc != "" {
            $desc
          } else {
            $ip
          }
        } catch {
          $ip
        }
      }
  }
 
  let subnetNameFromId = { |id|
      try {
        $subnets
        | where SubnetId == $id
        | first
        | get Name
      } catch {
        ""
      }
  }
 
  ^aws logs get-query-results --query-id $queryId
  | from json
  | get results
  | each { transpose --as-record --header-row | reject @ptr }
  | tee { save -f /tmp/tmp-results.nuon }
  | default "" pktSrcAwsService
  | default "" pktDstAwsService
  | move --after srcPort pktSrcAwsService
  | move --after dstPort pktDstAwsService
  | default "" instanceId
  | move --before interfaceId instanceId
  | update start { ($in | into int) * 1_000_000_000 | into datetime }
  | update end { ($in | into int) * 1_000_000_000 | into datetime }
  | insert duration { $in.end - $in.start }
  | move --after end duration
  | update srcPort {into int}
  | update dstPort {into int}
  | insert srcAddrDesc { |row| do $descriptionFromIp $row.srcAddr }
  | move srcAddrDesc --after srcAddr
  | insert dstAddrDesc { |row| do $descriptionFromIp $row.dstAddr }
  | move dstAddrDesc --after dstAddr
  | insert subnetName { |row| do $subnetNameFromId $row.subnetId }
  | move subnetName --after subnetId
  | collect
}

