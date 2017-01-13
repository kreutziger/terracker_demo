PACKER_VALIDATE_CMD:= bin/packer validate -var-file=packer/common_vars.json packer/$(ENV)/$(ENV).json
PACKER_BUILD_CMD := bin/packer build -var-file=packer/common_vars.json packer/$(ENV)/$(ENV).json

validate:
	@aws --version >/dev/null 2>&1 || { echo "AWS cli is not installed !	Aborting." >&2; exit 100; }
	@bin/packer version >/dev/null 2>&1 || { echo "packer is not installed !	Aborting." >&2; exit 100; }

packer_validate: init validate
	@$(PACKER_VALIDATE_CMD)

build_mi_$(ENV): packer_validate
	@$(PACKER_BUILD_CMD)

destroy_mi_$(ENV): init
	@aws --region=eu-central-1 ec2 describe-images --filters "Name=name,Values=$(ENV)" | grep ImageId | cut -d'"' -f 4 >$(TARGET_FOLDER)/$(ENV).imagesid
	@aws --region=eu-central-1 ec2 describe-images --filters "Name=name,Values=$(ENV)" | grep SnapshotId | cut -d'"' -f 4 >$(TARGET_FOLDER)/$(ENV).snapshotid
	@cat $(TARGET_FOLDER)/$(ENV).imagesid | xargs -L 1 aws --region=eu-central-1 ec2 deregister-image --image-id
	@cat $(TARGET_FOLDER)/$(ENV).snapshotid | xargs -L 1 aws --region=eu-central-1 ec2 delete-snapshot --snapshot-id
