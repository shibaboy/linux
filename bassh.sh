#!/bin/bash

OPTIONS=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text) "QUIT")

NAME=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`] | [0].Value]' --filters Name=instance-state-name,Values=running --output text))

#OPTIONS=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value[]]' --filters Name=instance-state-name,Values=running --output text) "QUIT")

echo 'Your running instances are: '
COUNTER=0
for ((i=0; i<${#OPTIONS[@]}; i++)); do
     COUNTER=$((COUNTER+1));
     echo "$COUNTER) ${OPTIONS[i]} ${NAME[i]]}";
done



#for ((i=0;i<${#array[@]};++i)); do
#    printf "%s is in %s\n" "${OPTIONS[i]}" "${NAME[i]}"
#done

#echo ${OPTIONS[@]} 


PS3='Please enter your choice: '
#QUIT="QUIT THIS PROGRAM"
#touch "$QUIT"

select INSTANCE in "${OPTIONS[@]}"
do
	case $INSTANCE in
                "QUIT")
		   break
		   ;;
		*)
		   export INSTANCE=$INSTANCE
                   echo -e "You chose ($REPLY) $INSTANCE\t\c";
                   echo ""
                   PUBLICDNS=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PublicDnsName]' --filters "Name=instance-state-name,Values=running" "Name=instance-id, Values=$INSTANCE" --output text))                              KEYNAME=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[KeyName]' --filters "Name=instance-state-name,Values=running" "Name=instance-id, Values=$INSTANCE" --output text))
                   exec ssh -i "$KEYNAME" ec2-user@$PUBLICDNS
		   ;;
	esac
done


