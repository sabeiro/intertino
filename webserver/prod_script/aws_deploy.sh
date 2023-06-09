if [[ -z "$1" ]]; then
    echo "Must provide a zip file"
    exit 1
fi
appN=${1/.zip/}
bucket="dauvi"
envN="Kotoba-env"
version="3"
aws s3 cp $1 s3://$bucket/$appN/$1
aws elasticbeanstalk create-application-version --application-name $appN --version-label ${appN}$version --source-bundle S3Bucket=$bucket,S3Key=$appN/$1
aws elasticbeanstalk update-environment --application-name $appN --environment-name $envN --version-label ${appN}$version
