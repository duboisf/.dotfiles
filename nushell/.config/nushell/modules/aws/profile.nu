# List currently configured AWS profiles
export def aws-profiles []: nothing -> table<profile: string> {
  ^aws configure list-profiles | lines | wrap profile
}
