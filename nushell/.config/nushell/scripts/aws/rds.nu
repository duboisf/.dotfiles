use wrapper.nu *

export def "rds logs list" [
    instance: string@"rds instances list", # the RDS instance to list logs for
    oldest?: duration, # return only the logs that were last written to before this time
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

def cache [] { 
    let cachePath = '~/.cache/completion.nuon'
    if not ($cachePath | path exists) {
        {} | save $cachePath
    }
    open $cachePath
}

export def "completion cache get" [key: string]: nothing -> record<lastUpdate: datetime, items: list<string>> {
    cache | get -i $key | default { lastUpdate: null, items: [] }
}

def "completion rds instances list" [context: string]: nothing -> list<string> {
    completion cache get rds.instances | get items
}

def "completion rds logs get" [context: string]: nothing -> list<string> {
    rds logs list ($context | split row -r '\s+' | get 3) | get LogFileName
}

export def "rds logs get" [
    instance: string@"completion rds instances list", # the RDS instance to get logs for
    filename?: string@"completion rds logs get", # the log file to download
    --oldest: duration, # return only the logs that were last written to before this time
    --all # download all logs
    -a # download all logs
]: nothing -> nothing {
    let downloadAll = $all or $a
    let downloadFile = { |filename|
        let cleanFilename = $filename | str replace "/" "_"
        print $"Downloading ($filename)"
        aws rds download-db-log-file-portion --db-instance-identifier $instance --log-file-name $filename --starting-token 0
            | save $"($instance)_($cleanFilename)"
    }
    if $downloadAll {
        rds logs list $instance $oldest
            | get LogFileName
            | par-each $downloadFile
    } else if $oldest != null {
        error make {
            msg: "Mutually exclusive options"
            label: {
                text: "You cannot specify both --oldest and a filename"
                span: (metadata $oldest).span
            }
        }
    } else if $filename != null {
        do $downloadFile $filename
    } else {
        error make {
            msg: "Missing required argument, you must specify either --all or a filename"
        }
    }
    print "Done!"
}

export def "rds instances list" []: nothing -> list<string> {
    aws rds describe-db-instances | get DBInstanceIdentifier
}
