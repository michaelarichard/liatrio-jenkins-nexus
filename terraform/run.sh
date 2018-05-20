#!/bin/bash

# pre-req - profile and crendials with authority configured in ~/.aws/credentials and ~/.aws/profile ( or your provisioner equivelent)
# pre-req - How do we handle keys? Make a new one for now if it doesn't exist.
if [ ! -e './ssh/liatrio-demo1.pem' ]; then
  mkdir -p ssh && ssh-keygen -f ssh/liatrio-demo1.pem -t rsa -N ''
fi

terraform init && terraform plan -out my_plan

terraform apply -auto-approve "my_plan"
