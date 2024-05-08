use config.nu
use get.nu

# Get Cloudflare DNS Records for a Zone
export def records [
  zone: string@"config zone names", # The zone to get the dns records for
  --max-items: int = 200 # Max records to display per page
]: nothing -> table {
  get with zones $zone dns_records [$"per_page=($max_items)"]
}
