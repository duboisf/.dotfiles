export def main []: nothing -> record<token: string, accounts: record<any>> {
  open ~/.config/cloudflare/config.json
}

export def base_url []: nothing -> string { "https://api.cloudflare.com/client/v4" }

export def auth []: nothing -> list<string> {
  [Authorization, $"Bearer (main | get token)"]
}

export def accounts []: nothing -> record<any> {
  main | get accounts
}

export def "account names" []: nothing -> list<string> {
  accounts | columns
}

export def zones []: nothing -> record<any> {
  main | get zones
}

export def "zone names" []: nothing -> list<string> {
  main | get zones | columns
}
