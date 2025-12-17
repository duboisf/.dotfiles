# Send a desktop notification. If the body is not provided, only the
# title is shown. If the body is provided, the title is shown as the
# header and the body is shown as the message.
export def notify [title: string, body?: string]: nothing -> nothing {
  if $body == null {
    printf $'\x1b]99;;($title)\x1b\\'
  } else {
    printf $'\x1b]99;i=1:d=0;($title)\x1b\\'
    printf $'\x1b]99;i=1:d=1:p=body;($body)\x1b\\'
  }
}

# Select columns interactively using the editor defined in $EDITOR.
# The first row in the input table is used to generate a sample data
# for each column. The user removes the lines of the columns they
# don't want to keep and saves the file. The selected columns are
# then returned as a list of strings.
export def "edit interactively" []: table -> list<string> {
  let input = $in
  # Save the column data to a temporary file and open it in the editor
  let tmpFile = mktemp -t
  $input | to text | save $tmpFile -f
  run-external $env.EDITOR $tmpFile

  # Read back the possibly edited file and return the selected column names
  open $tmpFile
  | lines
  | where { |line| not ($line | str starts-with '#') }
  | each { split row '#' | take 1 | str trim }
  | flatten
}

# Select columns interactively using the editor defined in $EDITOR.
# The first row in the input table is used to generate a sample data
# for each column. The user removes the lines of the columns they
# don't want to keep and saves the file.
# The input table is then filtered to only include the selected columns.
export def "pick columns" []: table -> list<string> {
  let input = $in

  # Use the first row to get the column names
  mut sample = $input | take 1 | get 0
  mut sample = $sample
    | columns
    | reduce --fold $sample { |colName, acc|
      $acc | update $colName { |row|
        "# " + ($row | get $colName | to text)
      }
    }
    | table --theme none 
    | ansi strip
    | lines
    | each {str trim}
    | str join (char newline)

  let header = [
    "# Select the columns you want.",
    "# Do not remove the comment markers (#).",
    "# The format of the lines is:"
    "# <column name>     # <sample data>"
  ] | str join (char newline)

  let columnData = $header + (char newline) + $sample
  let selectedColumns = $columnData
  | edit interactively
  | lines
  | where { |line| not ($line | str starts-with '#') }
  | each { split row '#' | take 1 | str trim }
  | flatten

  $selectedColumns
}

# Convert the input table to a SQLite database
export def "as sqlite" []: table<any> -> any {
  let input = $in
  let db_path = mktemp -t --suffix .sqlite
  $input | into sqlite $db_path
  open $db_path
}

# Rename files in the current directory that match the given regex.
# The new names will be prefixed with the given prefix and a number
# to that starts at 1 and increments for each file.
export def "rename-file" [
  regex: string # The regex to match the file name
  replacement_prefix: string # The prefix to add to the replacement
  --interactive = true # Whether to prompt before renaming if the file already exists
] {
  ls
  | where name =~ $regex
  | enumerate
  | each { |e|
    let old_name = $e.item.name
    let new_name = $"($replacement_prefix)-($e.index + 1).($old_name | path parse | get extension)"
    let args = [(if $interactive { "-i" } else { "" })]
    ^mv ...$args $old_name $new_name
  }
  null
}
