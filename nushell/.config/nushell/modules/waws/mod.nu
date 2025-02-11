export module waws/profile.nu
export module waws/logs.nu
export module waws/rds.nu
export module waws/wrapper.nu

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
# To retrieve the history, use the `history` command. It returns a table with
# the id, timestamp, command and result of each command.
# There are also two special commands to retrieve the last command and its result:
# - `history last`: returns the history table row of the last command
# - `history last result`: returns the result of the last aws command
#
# It also has a special cases for certain commands like `help` and the
# `resource-explorer-2` command that returns the results directly
# instead of the first key of the result.
# export def --wrapped main [
#   ...rest # The normal aws arguments and options, just don't add --output=json as it's added automatically!
# ]: nothing -> list<any> {
#   waws ...$rest    
# }
