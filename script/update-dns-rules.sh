#!/bin/bash
LC_ALL='C'

update_time="$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')(GMT+8)"

cp ./mod/rules/*rule* ./tmp/dns/

cat ./tmp/dns/* | grep -Ev '[A-Z]' |grep -vE '@|:|\?|\$|\#|\!|/' | sort | uniq >dns.txt

hostlist-compiler -c ./script/dns-rules-config.json -o dns-output.txt 

cat dns-output.txt |grep -P "^\|\|[a-z0-9\.\-\*]+\^$"> dns.txt
cat ./mod/rules/first-dns-rules.txt >> dns.txt
python ./script/rule.py dns.txt
echo -e "! Total count: $(wc -l < dns.txt) \n! Update: $update_time" > total.txt
cat ./mod/title/dns-title.txt total.txt dns.txt | sed '/^$/d' > tmp.txt && mv tmp.txt dns.txt


echo "# Title:AdRules Quantumult X List " > qx.conf
echo "# Title:AdRules SmartDNS List " > smart-dns.conf
echo "# Title:AdRules List " > adrules.list
echo "# Update: $update_time" >> qx.conf 
echo "# Update: $update_time" >> smart-dns.conf 
echo "# Update: $update_time" >> adrules_domainset.txt 
echo "# Update: $update_time" >> adrules.list 

cat dns.txt |grep -vE '(@|\*)' |grep -Po "(?<=\|\|).+(?=\^)" | grep -v "\*" |sed 's/^/host-suffix,/g'|sed 's/$/,reject/g' >> ./qx.conf
cat dns.txt |grep -vE '(@|\*)' |grep -Po "(?<=\|\|).+(?=\^)" | grep -v "\*" |sed "s/^/address \//g"|sed "s/$/\/#/g" >> ./smart-dns.conf
cat dns.txt |grep -vE '(@|\*)' |grep -Po "(?<=\|\|).+(?=\^)" | grep -v "\*" |sed "s/^/domain:/g" > ./mosdns_adrules.txt
cat dns.txt |grep -vE '(@|\*)' |grep -Po "(?<=\|\|).+(?=\^)" | grep -v "\*" |sed "s/^/\+\./g" >> ./adrules_domainset.txt
cat dns.txt |grep -vE '(@|\*)' |grep -Po "(?<=\|\|).+(?=\^)" | grep -v "\*" |sed "s/^/DOMAIN-SUFFIX,/g" >> ./adrules.list

rm dns-output.txt total.txt

exit
