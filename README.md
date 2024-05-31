# ipupdater

ipupdater updates a Cloudflare DNS record with your current public IP address. It checks your public IP and updates the DNS record if there has been a change since the last update. This ensures that your domain always points to your current IP.

## Setup


### Prerequisites

- A Unix operating system (Linux, Ubuntu, Debian, etc.)
- `curl` installed
- Cloudflare account with API key
- A Domain on Cloudflare
- Your DNS zone ID and record ID from Cloudflare

### Installation

1. **Clone the repository**:
    The repository should be cloned in the directory you wish to store ipupdater (e.g. `/etc`)
    ```sh
    git clone https://github.com/ardelerro/ipupdater.git
    cd ipupdater
    ```

2. **Make the script executable**:
    ```sh
    sudo chmod +x /etc/ipupdater/ipupdater.sh
    ```

3. **Set environment variables**:
    Edit the `ip_updater.sh` file to replace placeholders with your actual Cloudflare details:

    ```sh
    ZONE_ID="your_cloudflare_zone_id"
    RECORD_ID="your_cloudflare_record_id"
    AUTH_KEY="your_cloudflare_api_key"
    DOMAIN="example.com"
    ```
    The `LOG_FILE` variable can be changed to a diferent path or file if you prefer

### Usage

Run the script manually:

```sh
sudo /etc/ipupdater/ip_updater.sh
```

Run the script automatically:

a cronjob can be set up to run the script after every interval of time

#### Setup Cronjob

1. **Open cron file**
    ```sh
    crontab -e
    ```
2. **Edit the cron file**
    Add the following to your cron file in a new line to run the task every 15 miniutes:
    ``` sh
    */15 * * * * /path/to/ipupdater/ipupdater.sh
    ```
    see [this site](https://crontab.guru/) to create an interval for your cronjob
    
## Logging
The script logs all activities to `/etc/ipupdater/ip_update.log`. Check this log file for details about IP updates and any errors that occur.

The log file should be regularly monitored to check for errors
