source config.sh
aws ec2 run-instances --launch-template LaunchTemplateId=$TEMPLATE_ID --count=5  > /dev/null

echo "Started instances. Waiting 40sec for them to be ready."
sleep 20
echo "20sec"
sleep 10
echo "10sec"
sleep 10
echo "Starting setup."

source setup.sh
