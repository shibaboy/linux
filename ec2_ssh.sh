#!/bin/bash

OPTIONS=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' \
	--filters Name=instance-state-name,Values=running --output text) "QUIT")

NAME=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`] | [0].Value]' \
	--filters Name=instance-state-name,Values=running --output text))

#GetList=($(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
#	--query 'Reservations[*].{instance:Instances[].InstanceId | [0], tag:Instances[].Tags[?Key==`Name`].Value[]| [0]}' \
#	--output text) "QUIT")

echo 'Your running instances are: '
COUNTER=0
for ((i=0; i<${#OPTIONS[@]}; i++)); do
	COUNTER=$((COUNTER+1));
	echo "$COUNTER) ${OPTIONS[i]} ${NAME[i]]}";
done
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

PS3='Please enter your choice: '

select INSTANCE in "${OPTIONS[@]}"
do
	if [[ -z $INSTANCE ]]; then
		echo "Choose among the list"
		continue
	fi
	if [[ $INSTANCE == "QUIT" ]]; then
		echo "Finishing.."
		exit 0
	fi
	export INSTANCE=$INSTANCE
	echo "You chose ($REPLY) $INSTANCE\t\c";
	echo ""
	PUBLICDNS=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PublicDnsName]' \
		--filters "Name=instance-id, Values=$INSTANCE" --output text))                              
	KEYNAME=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[KeyName]' \
	--filters "Name=instance-id, Values=$INSTANCE" --output text))
	exec ssh -i ~/Documents/My_lab/"$KEYNAME".pem ec2-user@$PUBLICDNS
done


