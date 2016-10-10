#!/bin/bash

echo "Lab4 Destroy script"

echo "collect instance id's attached to the auto-scaling-group"
instance_id=$(aws autoscaling describe-auto-scaling-instances --query 'AutoScalingInstances[*].[InstanceId]')
echo "Instance ID selected"

echo "Set desired capacity to 0"
aws autoscaling set-desired-capacity --auto-scaling-group-name webserverdemo --desired-capacity 0
echo "Desired capacity set to 0"

echo "Wait until the instances are terminated"
echo $instance_id
aws ec2 wait instance-terminated --instance-ids $instance_id
echo "Wait is completed and instances in Running state are terminated"

sleep 30

echo "Deleting auto-scaling-group"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name webserverdemo
echo "AutoScaling group-name deleted"

echo "Deleting launch-configuration-group"
aws autoscaling delete-launch-configuration --launch-configuration-name webserver
echo "Launch configuration deleted"

echo "Deleting load-balancer"
aws elb delete-load-balancer --load-balancer-name itmo-544
echo "Load-balancer deleted"
