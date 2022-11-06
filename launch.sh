source config.sh
aws ec2 run-instances --launch-template LaunchTemplateId=$TEMPLATE_ID --count=5  > /dev/null

echo "Started instances. Waiting 60sec for them to be ready."
sleep 30
echo "30sec"
sleep 20
echo "10sec"
sleep 10
echo "Starting setup."

source setup.sh
