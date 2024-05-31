
# Variables
ZONE_ID="your_cloudflare_zone_id"
RECORD_ID="your_cloudflare_record_id"
AUTH_KEY="your_cloudflare_api_key"
DOMAIN="example.com"
API_URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID"
CURRENT_IP_FILE="/etc/ipupdater/current_ip.txt"
LOG_FILE="/etc/ipupdater/ip_update.log"


# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Get the current public IP
get_public_ip() {
  ip=$(curl -s https://api.ipify.org)
  if [ -z "$ip" ]; then
    return 1
  fi
  echo "$ip"
  return 0
}

# Update DNS record
update_dns_record() {
  local new_ip="$1"
  local payload=$(cat <<EOF
{
  "type": "A",
  "name": "$DOMAIN",
  "content": "$new_ip",
  "ttl": 60,
  "proxied": true,
  "comment": "Domain verification record updated by ipupdater"
}
EOF
)
  
  response=$(curl -s -X PUT "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_KEY" \
    --data "$payload")

  echo "$response"
  return $(echo "$response" | grep -q '"success":true' && echo 0 || echo 1)
}

# Read the stored current IP
if [ -f "$CURRENT_IP_FILE" ]; then
  current_ip=$(cat "$CURRENT_IP_FILE")
else
  current_ip=""
fi

# Get the new public IP
new_ip=$(get_public_ip)

if [ $? -ne 0 ]; then
  log_message "Error: Unable to get public IP."
  exit 1
fi

# Compare IPs and update if different
if [ "$new_ip" != "$current_ip" ]; then
  log_message "Updating DNS record from $current_ip to $new_ip..."
  update_dns_record "$new_ip"
  if [ $? -eq 0 ]; then
    log_message "Public IP updated to: $new_ip"
    echo "$new_ip" > "$CURRENT_IP_FILE"
  else
    log_message "Failed to update DNS record"
  fi
else
  log_message "Public IP is the same: $new_ip"
fi
