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

echo "Checking Vault Network Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-core-networking.json

echo ""
echo "Checking Vault Security Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-core-security.json

echo ""
echo "Checking Vault Instances Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-core-instances.json

echo ""
echo "Checking Application Network Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-app-networking.json

echo ""
echo "Checking Application Security Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-app-security.json

echo ""
echo "Checking Application Instances Template..."
echo ""

aws cloudformation validate-template --template-body file://vault-app-instances.json

}

create_cf_stack () {

clear

echo "---------------------------------------------------------------------------------------"
echo "BUILDING CLOUDFORMATION STACK..."
echo "---------------------------------------------------------------------------------------"

echo ""

echo "Enter the name of the MAIN AWS profile you wish to use."
echo "This will be the profile of the account in which the Vault environment is to be created. (Leave blank for 'default' profile)..."
echo ""

read -p "> " profile

if [ -z "$profile" ]; then
    profile="default"
fi

echo ""

echo "Enter the name of the SECONDARY AWS profile you wish to use."
echo "This will be the profile of the account in which the Reference Application environment is to be created. (Leave blank for 'default' profile)..."
echo ""

read -p "> " profile2

if [ -z "$profile2" ]; then
    profile2="default"
fi

echo ""

echo "Enter the name of the Cloudformation Stack..."
echo ""

read -p "> " stackname
stackname_parsed=$(echo $stackname | tr ' ' '-')

echo ""
echo "What AWS Region will this be installed in? (e.g. eu-west-1)..."
echo ""

read -p "> " regionname

echo ""
echo "How many subnets do you require? (2 is default)"
echo "N.B. Please make sure the number of subnets matches the region you choose (No checking is done on this)..."
echo ""

read -p "> " subnetnumber

if [ -z "$subnetnumber" ]; then
    subnetnumber="2"
fi

echo ""
echo "Creating Stack: "$stackname_parsed"-1 ..."
echo ""

aws --profile $profile --region $regionname cloudformation create-stack --stack-name $stackname_parsed"-1" --template-body file://vault-core-networking.json --parameters file://vault-core-networking-parameters.json --capabilitie CAPABILITY_IAM

aws --profile $profile --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-1"
while [ $? -ne 0 ]; do
    aws --profile $profile --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-1"
    sleep 3
done

if [ $? -eq 0 ]; then
{
  echo ""
  echo "Creating Stack: "$stackname_parsed"-2 ..."
  echo ""
}
fi

aws --profile $profile cloudformation create-stack --stack-name $stackname_parsed"-2" --template-body file://vault-core-security.json --parameters ParameterKey=NumberOfSubnetNodes,ParameterValue=$subnetnumber ParameterKey=VaultStackName,ParameterValue=$stackname_parsed"-1" --capabilities CAPABILITY_IAM

aws --profile $profile --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-2"
while [ $? -ne 0 ]; do
    aws --profile $profile --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-2"
    sleep 3
done

if [ $? -eq 0 ]; then
{
  echo ""
  echo "Creating Stack: "$stackname_parsed"-3 ..."
  echo ""
}
fi

aws --profile $profile cloudformation create-stack --stack-name $stackname_parsed"-3" --template-body file://vault-core-instances.json --parameters  ParameterKey=NumberOfSubnetNodes,ParameterValue=$subnetnumber ParameterKey=VaultChildStackName,ParameterValue=$stackname_parsed"-2" --capabilities CAPABILITY_IAM


aws --profile $profile --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-3"
while [ $? -ne 0 ]; do
    aws --profile $profile --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-3"
    sleep 3
done

#if [ $? -eq 0 ]; then
#{
#  echo ""
#  echo "Creating Stack: "$stackname_parsed"-App-1 ..."
#  echo ""
#}
#fi

#aws --profile $profile2 --region $regionname cloudformation create-stack --stack-name $stackname_parsed"-App-1" --template-body file://vault-app-networking.json --parameters file://vault-app-networking-parameters.json --capabilities CAPABILITY_IAM --region eu-west-1

#aws --profile $profile2 --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-App-1"
#while [ $? -ne 0 ]; do
#    aws --profile $profile2 --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-App-1"
#    sleep 3
#done

#if [ $? -eq 0 ]; then
#{
#  echo ""
#  echo "Creating Stack: "$stackname_parsed"-App-2 ..."
#  echo ""
#}
#fi

#aws --profile $profile2 --region $regionname cloudformation create-stack --stack-name $stackname_parsed"-App-2" --template-body file://vault-app-security.json --parameters  ParameterKey=VaultStackName,ParameterValue=$stackname_parsed"-App-1" --capabilities CAPABILITY_IAM

#aws --profile $profile2 --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-App-2"
#while [ $? -ne 0 ]; do
#    aws --profile $profile2 --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-App-2"
#    sleep 3
#done

#if [ $? -eq 0 ]; then
#{
#  echo ""
#  echo "Creating Stack: "$stackname_parsed"-App-3 ..."
#  echo ""
#}
#fi

#aws --profile $profile2 --region $regionname cloudformation create-stack --stack-name $stackname_parsed"-App-3" --template-body file://vault-app-instances.json --parameters  ParameterKey=VaultChildStackName,ParameterValue=$stackname_parsed"-App-2" --capabilities CAPABILITY_IAM

#aws --profile $profile2 --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-App-3"
#while [ $? -ne 0 ]; do
#    aws --profile $profile2 --region $regionname cloudformation wait stack-create-complete --stack-name $stackname_parsed"-App-3"
#    sleep 3
#done

if [ $? -eq 0 ]; then
{
  echo ""
  echo "All Stacks Created Successfully."
  echo ""
}
fi

}

clear
menu
