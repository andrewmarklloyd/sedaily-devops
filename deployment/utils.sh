#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
KEY="prod.pem"
IP="grafana.lvh.me"

function ec2IP() {
	cd ./terraform
	IP=$(terraform output -json | jq -r '.instance_ip_addr.value')
	cd ${DIR}
}

function connect() {
	ssh -i "prod.pem" ec2-user@${IP}
}

function terraformVars() {
	echo "public_cidr_block = \"$(dig +short myip.opendns.com @resolver1.opendns.com)\"" > ./terraform/terraform.tfvars
}

function copyConfig() {
	file=grafana
	cat assets/${file}.config.env | sed "s/<domain>/${IP}/g" > ${file}.config.env
	scp -i prod.pem assets/influx.config.env grafana.config.env ec2-user@${IP}:/home/ec2-user/app/
	rm grafana.config.env
}

function start() {
	ssh -i prod.pem ec2-user@${IP} "cd app/; docker-compose up -d"
}

function stop() {
	ssh -i prod.pem ec2-user@${IP} "cd app/; docker-compose down; sudo rm -rf influx-data grafana-data"
}

function password() {
	curl -s https://passwordwolf.com/api/\?length\=20 | jq -r '.[0].password'
}

function browser() {
	open http://${IP}
}

function readEnvVars() {
	file=$1
	while IFS=$'=' read -r -a myArray
	do
		if [[ ! -z "${myArray[0]}" && "${myArray[0]}" != *\#* ]]; then
			export "${myArray[0]}"="${myArray[1]}"
		fi
	done < ${file}
}

function createDataSources() {
	cat assets/grafana.config.env | sed "s/<domain>/${IP}/g" > grafana.config.env
	readEnvVars grafana.config.env
	for i in assets/data_sources/*; do \
    curl -X "POST" "https://${GF_SERVER_DOMAIN}/api/datasources" \
    -H "Content-Type: application/json" \
     --user "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
     --data-binary @$i
	 done
}

function restore() {
	scp -i prod.pem -r old-instance/backup ec2-user@${IP}:/home/ec2-user/app
ssh -i prod.pem -t ec2-user@${IP} << EOF
docker run --rm \
--entrypoint /bin/bash \
-v /home/ec2-user/app/influx-data:/var/lib/influxdb \
-v /home/ec2-user/app/backup/:/backups \
influxdb:1.4.3 \
-c "influxd restore -metadir /var/lib/influxdb/meta -datadir /var/lib/influxdb/data -database eventsDb /backups"
docker-compose -f /home/ec2-user/app/docker-compose.yml up -d
rm -rf /home/ec2-user/app/backup/
EOF
}

if [[ ${1} == 'connect' ]]; then
	ec2IP
	connect
elif [[ ${1} == 'vars' ]]; then
	terraformVars
elif [[ ${1} == 'copy-config' ]]; then
	ec2IP
	copyConfig
elif [[ ${1} == 'browser' ]]; then
	ec2IP
	browser
elif [[ ${1} == 'start' ]]; then
	ec2IP
	start
elif [[ ${1} == 'stop' ]]; then
	ec2IP
	stop
elif [[ ${1} == 'ip' ]]; then
	ec2IP
	echo ${IP}
elif [[ ${1} == 'pw' ]]; then
	password
elif [[ ${1} == 'set-sources' ]]; then
	ec2IP
	createDataSources
elif [[ ${1} == 'set-dashboards' ]]; then
	createDashboard
elif [[ ${1} == 'restore' ]]; then
	ec2IP
	restore
fi
