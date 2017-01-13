TARGET_FOLDER := target
OPERATION := $(word 1,$(subst _, ,$(MAKECMDGOALS)))
PROJECT := $(word 2,$(subst _, ,$(MAKECMDGOALS)))
ENV := $(word 3,$(subst _, ,$(MAKECMDGOALS)))

TERRAFORM_PLAN_CMD := cd $(TARGET_FOLDER) ; ../bin/terraform plan -var-file=$(ENV).tfvars
TERRAFORM_APPLY_CMD := cd $(TARGET_FOLDER) ; ../bin/terraform apply -var-file=$(ENV).tfvars
TERRAFORM_DESTROY_CMD := cd $(TARGET_FOLDER) ; ../bin/terraform destroy -var-file=$(ENV).tfvars
TERRAFORM_VALIDATE_CMD := cd $(TARGET_FOLDER) ; ../bin/terraform validate .
TERRAFORM_STATE_FILE := $(PROJECT)-$(ENV).tfstate

$(info OPERATION : $(OPERATION))
$(info PROJECT : $(PROJECT))
$(info ENV : $(ENV))

.PHONY: validate clean

ifndef AWS_ACCESS_KEY_ID
$(warning AWS_ACCESS_KEY_ID was not set like env variable)
endif

ifndef AWS_SECRET_ACCESS_KEY
$(warning AWS_SECRET_ACCESS_KEY was not set like env variable)
endif

validate:
	@bin/terraform -v >/dev/null 2>&1 || { echo "terraform is not installed ! Aborting." >&2; exit 100; }
	@aws --version >/dev/null 2>&1 || { echo "AWS CLI is not installed !	Aborting." >&2; exit 100; }

install_tools:
	@./install/update_go_tools.sh

clean:
	@rm -fr $(TARGET_FOLDER)

init: validate clean
	@mkdir $(TARGET_FOLDER)

get_state:
	@-cp states/$(TERRAFORM_STATE_FILE) $(TARGET_FOLDER)/terraform.tfstate

preparation : init get_state
	@cp ./terraform/$(PROJECT)/vars/$(ENV).tfvars $(TARGET_FOLDER)
	@cp ./terraform/$(PROJECT)/*.* $(TARGET_FOLDER)

tf_validate : preparation
	@$(TERRAFORM_VALIDATE_CMD) $(TARGET_FOLDER)

plan_% : tf_validate
	@$(TERRAFORM_PLAN_CMD)

apply_% : tf_validate
	@$(TERRAFORM_APPLY_CMD)
	@cp $(TARGET_FOLDER)/terraform.tfstate states/$(TERRAFORM_STATE_FILE)

destroy_% : tf_validate
	@mv states/$(TERRAFORM_STATE_FILE) $(TARGET_FOLDER)/terraform.tfstate 
	@$(TERRAFORM_DESTROY_CMD)

ifeq ($(PROJECT),mi)
-include ./packer/Makefile
else
-include ./terraform/$(PROJECT)/Makefile
endif
