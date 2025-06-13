export def "asana pat" [] {
    open ~/.asana | from json | get pat
}

export def "asana workspace" [] {
    open ~/.asana | from json | get workspace-gid
}

export def "asana me" [] {
    http get -H {
        Content-Type: application/json,
        Authorization: $'Bearer (asana pat)'
    } https://app.asana.com/api/1.0/users/me | get data
}

export def "asana my tasks" [since: datetime] {
    use std log
    let params = {
        opt_fields: "completed_at,name,notes",
        assignee.any: (asana me | get gid),
        sort_by: completed_at,
        sort_ascending: "true"
    }
    def fetch [since, cumul] {
        log debug $"fetching ($since)"
        let joined_params = ($params | upsert 'completed_at.after' $since | items {|k, v| $k + '=' + $v} | str join "&")
        let results = http get -H {
            Content-Type: application/json,
            Authorization: $'Bearer (asana pat)'
        } $'https://app.asana.com/api/1.0/workspaces/(asana workspace)/tasks/search?($joined_params)' | get data
        if ($results | length) == 100 {
            let next_since = ($results | last | get completed_at)
            fetch $next_since ($cumul ++ $results)
        } else {
            $cumul ++ $results
        }
    }
    fetch ($"($since | format date "%F")T00:00:00.000Z") []
}

export def "asana to markdown" [] {
    each { |task|
        ([
            $"# ($task.name)"
            $"_Completed on ($task.completed_at | into datetime | date to-timezone local)_"
            $task.notes
        ] | compact | str join "\n\n" | str trim --right) + "\n"
    } | to text
}
