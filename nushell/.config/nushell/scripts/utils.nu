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
  | filter { |line| not ($line | str starts-with '#') }
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
  | filter { |line| not ($line | str starts-with '#') }
  | each { split row '#' | take 1 | str trim }
  | flatten

  $selectedColumns
}

# Convert the input table to a SQLite database
export def "as sqlite" []: table<any> -> any {
  let input = $in
  let db_path = mktemp -t --suffix .sqlite
  $input | into sqlite $db_path
  stor import --file-name $db_path
  rm $db_path
  stor open
}
