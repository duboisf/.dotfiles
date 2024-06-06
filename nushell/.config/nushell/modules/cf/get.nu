use config.nu

export def "with" [type: string, type_name: string, path: string, query_params: list<string> = []]: nothing -> table {
  let type_id = config | get $type | get $type_name
  let params = if ($query_params | length) > 0 {
    "?" + ($query_params | str join '&')
  } else {
    ""
  }
  let url = $"(config base_url)/($type)/($type_id)/($path)($params)"
  let resp = http get -H (config auth) $url
  let json_resp = match ($resp | describe) {
    # For some reason some endpoints (like devices/posture/integration) return json but with content-type: text/plain
    "string" => ($resp | from json)
    _ => $resp
  }
  $json_resp | get result
}

