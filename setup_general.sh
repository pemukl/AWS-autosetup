echo "General Setup started."
source config.sh
echo "Cloning Git repo."
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
git clone $MY_GITHUB

echo "Downloading from S3 bucket."
aws s3 sync s3://dsc102-public ./downloads

