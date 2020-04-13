#!/bin/bash -e

create_deployment_package()
{
    cd $1
    echo "Adding function code to zip file..."
    zip -r9 function.zip *.py -x *_test.py

    # If the dependencies directory doesn't exist, then don't bother trying to add it
    if [ -d packages ]; then
        echo "Adding dependencies to zip file..."
        cd packages
        zip -g ../function.zip .
    fi
    
    echo "Deployment package complete."
}

upload_lambda_code()
{
    cd $2
    echo "Updating $1"

    # Hardcodeding the handler, the placeholder uses placeholder.handler
    aws lambda update-function-configuration --function-name $1 --handler hello.handler
    NEW_VERSION=$(aws lambda update-function-code --function-name $1 --zip-file fileb://function.zip --publish | jq -r .Version)
    echo "Setting target alias to version $NEW_VERSION"
    aws lambda update-alias --function-name $1 --name production --function-version $NEW_VERSION
    
    echo "$1 updated."
}

validate_params()
{
    # First argument should be the function name
    echo "Validating target function exists..."
    aws lambda get-function --function-name $1

    # Second argument should be the app directory
    echo "Validating function directory exists..."
    if [ ! -d $2 ]; then
        echo "Directory $2 does not exist"
        exit 1
    fi
    
    echo "Input params are valid."
}

print_usage()
{
    echo "usage: deploy_lambdas.sh FUNCTION_NAME FUNCTION_DIRECTORY"
}

# If we've been given a relative path for the fucntion directory, change it to absolute
if [ "${2:0:1}" = "/" ]; then
    DIR=$2
else
    DIR=$PWD/$2
fi

validate_params $1 $DIR
create_deployment_package $DIR
upload_lambda_code $1 $DIR