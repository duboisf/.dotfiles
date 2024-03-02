use wrapper.nu *
use std

export def "cache get" [key: string, populate: closure]: nothing -> record<items: list<string>, last_access?: datetime> {
  if (stor open | schema | get tables.aws_completions?) == null {
    stor create -t $"aws_completions" -c { key: str, items: str, last_access: datetime }
  }
  let entry = stor open | query db $"select items, last_access from aws_completions where key = '($key)'"
  std log debug $"Cache entry for key ($key): ($entry)\n"
  if $entry == [] {
    let entry = {key: $key, items: (do $populate | to nuon), last_access: (date now)}
    stor insert -t aws_completions -d $entry
    return (cache get $key $populate)
  }
  let entry = $entry | get 0 | update items {from nuon} | update last_access {into datetime}
  if $entry.last_access < (date now) - 15sec {
    std log debug $"entry for key ($key) expired, deleting\n"
    stor delete -t aws_completions --where-clause $"key = '($key)'"
    return (cache get $key $populate)
  }
  $entry
}

export def "completion instances list" [context: string]: nothing -> list<string> {
  let populate = {||
    std log debug "Populating RDS instances list\n"
    let res = instances list
    std log debug $"Result of RDS instances list: ($res)\n"
    $res
  }
  cache get rds_instances $populate | get items
}

def "completion logs get" [context: string]: nothing -> list<string> {
    rds logs list ($context | split row -r '\s+' | get 3) | get LogFileName
}

export def "logs list" [
    instance: string@"completion instances list", # the RDS instance to list logs for
    --oldest: duration, # return only the logs that were last written to before this time
    -o: duration, # return only the logs that were last written to before this time
]: nothing -> list<string> {
    let logFiles = (aws rds describe-db-log-files --db-instance-identifier $instance
    | update LastWritten { $in * 1_000_000 | into datetime } 
    | update Size { into filesize }
    | where Size > 0b)
    (if $oldest != null {
        $logFiles | where LastWritten >= ((date now) - $oldest)
    } else {
        $logFiles
    })
}

export def "logs get" [ 
    instance: string@"completion instances list", # the RDS instance to get logs for
    filename?: string@"completion logs get", # the log file to download
    --oldest: duration, # return only the logs that were last written to before this time
    -o: duration, # return only the logs that were last written to before this time
]: nothing -> nothing {
    let downloadFile = { |filename|
        let cleanFilename = $filename | str replace "/" "_"
        print -e $"Downloading ($filename)"
        aws rds download-db-log-file-portion --db-instance-identifier $instance --log-file-name $filename --starting-token 0
            | save $"($instance)_($cleanFilename)"
    }
    if $filename != null {
      do $downloadFile $filename
    } else {
        print -e "Downloading all logs"
        rds logs list $instance --oldest $oldest
            | get LogFileName
            | par-each $downloadFile
    }
    print -e "Done!"
}

export def "instances list" []: nothing -> list<string> {
    aws rds describe-db-instances | get DBInstanceIdentifier
}
