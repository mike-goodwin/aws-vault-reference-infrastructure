#!/usr/bin/env bash

# AWS profile used to differentiate between accounts
profile=$1

menu () {

echo "---------------------------------------------------------------------------------------"
echo "AWS VAULT REFERENCE INSTALLATION"
echo "---------------------------------------------------------------------------------------"

echo ""

echo "Select from the following options..."

echo ""
cat << _EOF_

1. VALIDATE CLOUDFORMATION TEMPLATES

2. BUILD CLOUDFORMATION STACK

0. Quit

_EOF_

echo ""

read -n 1 -p "Enter Selection [0-2] > "

if [[ $REPLY =~ ^[0-2]$ ]]; then

echo ""
    case $REPLY in
      1)
        validate_cf
        footer
        ;;
      2)
        create_cf_stack
        footer
        ;;
      0)
        clear
        ;;
    esac

else
    echo "** An Invalid Option Has Been Pressed **"
    sleep 5
fi
}

footer () {

cat << _EOF_

---------------------------------------------------------------------------------------
PRESS:         '0' to Exit | '1' for Menu
---------------------------------------------------------------------------------------

_EOF_

read -n1 -p " > "
echo ""

if [[ $REPLY =~ ^[0-2]$ ]]; then
    case $REPLY in
      1)
        clear
        menu
        ;;
      0)
        clear
        exit
        ;;
    esac
  else
    echo "*** An Invalid Option Has Been Pressed or Entered ***"
    sleep 5
  fi

}

validate_cf () {

clear

echo "---------------------------------------------------------------------------------------"
echo "VALIDATE CLOUDFORMATION TEMPLATES"
echo "---------------------------------------------------------------------------------------"

echo ""
echo "Checking Cloudformation Templates - Remedy any errors that appear before attempting to build the stack."
echo ""

sleep 5

echo "Checking Network Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-core-networking.json

echo ""
echo "Checking Security Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-core-security.json

echo ""
echo "Checking Security Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-core-instances.json

}

create_cf_stack () {

clear

echo "---------------------------------------------------------------------------------------"
echo "BUILD CLOUDFORMATION STACK"
echo "---------------------------------------------------------------------------------------"

echo ""

echo "Enter the name of the AWS profile you wish to use (Leave blank for 'default' profile)..."
echo ""

read -p "> " profile

if [ -z "$profile" ]; then
    profile="default"
fi

echo ""

echo "Enter the name of the Cloudformation Stack..."
echo ""

read -p "> " stackname
stackname_parsed=$(echo $stackname | tr ' ' '-')

echo ""

aws cloudformation create-stack --stack-name $stackname_parsed"-1" --template-body file://vault-core-networking.json --parameters file://vault-core-networking-parameters.json --capabilities CAPABILITY_IAM

sleep 200

aws cloudformation create-stack --stack-name $stackname_parsed"-2" --template-body file://vault-core-security.json --parameters  ParameterKey=VaultStackName,ParameterValue=$stackname_parsed"-1" --capabilities CAPABILITY_IAM

sleep 100

aws cloudformation create-stack --stack-name $stackname_parsed"-3" --template-body file://vault-core-instances.json --parameters  ParameterKey=VaultChildStackName,ParameterValue=$stackname_parsed"-2" --capabilities CAPABILITY_IAM

}

clear
menu