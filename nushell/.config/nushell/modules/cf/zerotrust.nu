# These are commands to help with calling the cloudflare API, written in nushell.
use config.nu

def "get with account" [account: string, path: string]: nothing -> table {
  let account_id = config accounts | get $account
  let resp = http get -H (config auth) $"(config base_url)/accounts/($account_id)/($path)"
  let json_resp = match ($resp | describe) {
    # For some reason some endpoints (like devices/posture/integration) return json but with content-type: text/plain
    "string" => ($resp | from json)
    _ => $resp
  }
  $json_resp | get result
}

# Get Cloudflare Zero Trust Applications
export def apps  [
  account: string@"config account names", # The account to get the apps for
]: nothing -> table {
  get with account $account access/apps
}

# Get Cloudflare Zero Trust Gateway rules
export def "gateway rules" [
  account: string@"config account names", # The account to get the policies for
]: nothing -> table {
  get with account $account gateway/rules
}

# Get Cloudflare Zero Trust Device Posture rules
export def "device posture rules" [
  account: string@"config account names", # The account to get the policies for
]: nothing -> table {
  get with account $account devices/posture
}

# Get Cloudflare Zero Trust Device Posture Integrations
export def "device posture integrations" [
  account: string@"config account names", # The account to get the policies for
]: nothing -> table {
  get with account $account devices/posture/integration
}
