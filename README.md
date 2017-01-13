# Overview
This is an example project to deploy mutliple nginx instances to AWS which are secured in a private network and can only be accessed via a load balancer. The nginx instances will be created with packer. The content of the files will be generated during the start of the nginx or with an S3 bucket.

The makefile handles all commands and is generic. You can easily add your own projects to the folder structure.

## Packer commands
`make build_mi_nginx` - This creates the packer image in AWS, be sure to fit the variables in the common_vars.json to your needs.
`make destroy_mi_nginx` - This removes the images from AWS again. If you want to build directly after that the images again, you will have to wait until they are fully derigstered from AWS or rename automatically the AMI on creation time, e. g. with a timestamp (packer supports this as an built-in variable).

## Terraform commands
`make plan_demo_dev` - This will plan the infrastructure to give you an overview of what will be created/deleted/changed.
`make apply_demo_dev` - This will apply the changes seen in the plan command.
