
echo "Welcome to Lab4"

if [ $# -ne 5 ]
then
echo "5 mandatory parameters \"AMI ID, key-name, security-group, launch-configuration and count \" should to be passed in the same order"

else
echo "Creating new instances"
aws ec2 run-instances --image-id $1 --key-name $2 --security-group-ids $3 --instance-type t2.micro --user-data file://installapp.sh --count $5 --placement AvailabilityZone=us-west-2a
echo "New Instance creation completed"

echo "Wait untill the Instance is moved to Running State"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId]' --filters Name=instance-state-name,Values=pending)
echo $instance_id
aws ec2 wait instance-running --instance-ids $instance_id
echo "Wait is completed and instances are now in Running state"

echo "Creating a Load Balancer"
aws elb create-load-balancer --load-balancer-name itmo-544 --listeners Protocol=Http,LoadBalancerPort=80,InstanceProtocol=Http,InstancePort=80 --subnets subnet-9a5f1eec
echo "Load balancer is  created successfully"

echo "Registering newly created instances with the load balancer"
aws elb register-instances-with-load-balancer --load-balancer-name itmo-544 --instances $instance_id
echo "Instances are registered to load balancer successfully"

echo "Creating Autoscaling Launch Configuration"
aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --instance-type t2.micro --user-data file://installapp.sh
echo "Autoscaling Launch Configuration created successfully"

echo "Creating Autoscaling Group"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name webserverdemo --launch-configuration $4 --availability-zone us-west-2a --max-size 5 --min-size 0 --desired-capacity 1
echo "AutoScaling Group Created Successfully"

echo "Attaching created instances to auto scaling group"
aws autoscaling attach-instances --instance-ids $instance_id --auto-scaling-group-name webserverdemo
echo "Instances attached to auto-scaling-group successfully"

echo "Attaching load balancer to auto scaling group"
aws autoscaling attach-load-balancers --auto-scaling-group-name webserverdemo --load-balancer-names itmo-544
echo "load balancer attached to auto-scaling-group successfully"

echo "Lab4 completed successfully"
fi
