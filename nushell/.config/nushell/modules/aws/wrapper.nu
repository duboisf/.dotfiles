
const hist_table_name = "_aws_results"

def "aws-history table exists" []: nothing -> bool {
  ((stor open | schema).tables | get --ignore-errors $hist_table_name) != null
}

def "aws-history store" [command: list<string>, result: closure]: nothing -> list<any> {
  if not (aws-history table exists) {
    stor create --table-name $hist_table_name -c {timestamp: datetime, command: str, result: str}
  }
  let result = do $result
  stor insert --table-name $hist_table_name --data-record {
    timestamp: (date now),
    command: ($command | str join " "),
    result: ($result| to nuon)
  }
  $result
}

# This command returns the in-memory history of the aws commands called.
export def "aws-history" []: nothing -> table<id: int, timestamp: datetime, command: string, result: any> {
  if not (aws-history table exists) {
    return []
  }
  stor open
  | query db "select * from _aws_results"
  | update id {into int}
  | update timestamp {into datetime}
  | update result {from nuon}
}

# This command returns the last command from the in-memory history.
export def "aws-history last" []: nothing -> record<id: int, timestamp: datetime, command: string, result: any> {
  if not (aws-history table exists) {
    return []
  }
  aws-history | last
}

# This command returns the result of the last aws command from the in-memory history.
export def "aws-history last result" []: nothing -> any {
  if not (aws-history table exists) {
    return []
  }
  (aws-history last).result
}

# This is a wrapper around the aws cli that automatically converts the results
# to json by appending the `--output=json` option to the command and passing it
# to the `into json` pipeline.
#
# Moreover, it also extracts the results from the first key of the returned
# json object. This is very useful as most aws cli commands return a json object
# with a single key (which is unique accross commands) that contains the actual
# results.
#
# Furthermore it keeps a history of the commands called in the in-memory sqlite
# db. No more "oops, I should have stored that last command in a variable!" moments.
#
# To retrieve the history, use the `aws-history` command. It returns a table with
# the id, timestamp, command and result of each command.
# There are also two special commands to retrieve the last command and its result:
# - `aws-history last`: returns the history table row of the last command
# - `aws-history last result`: returns the result of the last aws command
#
# It also has a special cases for certain commands like `help` and the
# `resource-explorer-2` command that returns the results directly
# instead of the first key of the result.
export def --wrapped aws [
  ...rest # The normal aws arguments and options, just don't add --output=json as it's added automatically!
]: nothing -> list<any> {
  if "help" in $rest {
      return (run-external aws ...$rest)
  }
  let args = [...$rest --output json]
  let output = ^aws ...$args | from json
  aws-history store [aws ...$args] {||
    for $arg in $rest {
        match $arg {
            "resource-explorer-2" => (return $output)
        }
    }
    $output | get-first-key
  }
}

# This function is used to get the first key of a record.
# 
# It's especially useful with the aws cli as the output is
# often a record with a single key that contains the actual
# results.
#
# Example:
#   > {
#       "Regions": [
#           {
#               "Endpoint": "ec2.ap-south-1.amazonaws.com",
#               "RegionName": "ap-south-1",
#               "OptInStatus": "opt-in-not-required"
#           },
#           ...
#       ]
#     } | get-first-key
#
#   Result:
#   [
#       {
#           "Endpoint": "ec2.ap-south-1.amazonaws.com",
#           "RegionName": "ap-south-1",
#           "OptInStatus": "opt-in-not-required"
#       },
#       ...
#   ]
export def "get-first-key" []: record -> any {
  let input = $in
  let firstKey = $input | columns | get 0
  $input | get $firstKey
}
