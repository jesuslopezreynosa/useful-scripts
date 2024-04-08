# Looks into a file called 'denylist.txt' where each domain is on each line 
# and runs the POST command to the NextDNS denylist endpoint. Just modify
# the $nextDnsId and $apiKeyHeader variables. Sleeps every 2s to prevent 
# being seen as a DDOS query

nextDnsId="xxxxxx"
apiKeyHeader="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

cat denylist.txt | while read line 
do
    data="{\"id\":\"${line}\",\"active\":true}";

    curl -X POST https://api.nextdns.io/profiles/${nextDnsId}/denylist \
        -H "X-Api-Key:${apiKeyHeader}" \
        -H "Content-Type:application/json" \
        -d "${data}";

    echo "${data}\n";
    sleep 2;
done