########################################################################################
# Allows updating IPv4 and IPv6 (if applicable) addresses for a DuckDNS domain
# name. Like the script provided from DuckDNS, the log file will say OK if 
# good and KO if an error occurred.
#
# Update your crontab w/ `*/5 * * * * ~/duckdns/updateDomainDynamic.sh >/dev/null 2>&1`
# and make sure the script is executable (chmod +x updateDomainDynamic.sh) beforehand.
########################################################################################

domain="INSERT DOMAIN NAME HERE"
duckDnsApiToken="xxxxxxx-xxxx-0000-0000-000000000"

url="https://www.duckdns.org/update?domains=${domain}&token=${duckDnsApiToken}&ip="
ipv6Addr=$(curl -6 ifconfig.co)
ipv4Addr=$(curl -4 ifconfig.co)

# Build Base URL
url="$url$ipv4Addr"

if [[ $ipv6Addr != *"Failed"* ]]
then
        ipv6Addr="&ipv6=$ipv6Addr"
        url="$url$ipv6Addr"
fi

echo $url

curl $url -o ~/duckdns/duck.log