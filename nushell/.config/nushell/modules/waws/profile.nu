# List currently configured AWS profiles
export def main []: nothing -> table<profile: string> {
  ^aws configure list-profiles | lines | wrap profile
}
