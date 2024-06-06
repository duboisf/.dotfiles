use config.nu
use get.nu

export def "ip access rules" [
  zone: string@"config zone names", # The zone to get the dns records for
]: nothing -> table {
  get with zones $zone firewall/access_rules/rules
}
