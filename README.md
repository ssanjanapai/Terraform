# My first terraform code

In the above files, I tried to implement a basic infrastructure.
At first I planned how my infrastructure must look like and then I read AWS docs to understand in-depth the concepts of VPC,subnets and CIDR addresses.

## Components
Here,with AWS as provider, I set up a VPC and a subnet within the VPC. I used the following components within the subnet:

- aws_internet_gateway
- aws_route_table
- aws_security_group
- aws_network_interface
- aws_eip
- aws_instance

## User Data

Learnt about user_data in terraform. Understood the importance of using this.
Example script:

```
user_data = << EOF
		#! /bin/bash
                sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
  ```
  
  When ```$terraform apply``` is run, the content in 'echo' is run by our instance.
  
  
 

