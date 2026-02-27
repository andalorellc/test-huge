# Terraform targets; CI runs these with PATH set so "terraform" uses the mock wrapper for apply.

.PHONY: init plan apply validate

init:
	rm -f terraform.tfstate terraform.tfstate.backup
	terraform init -reconfigure \
		-backend-config="bucket=$(TF_BACKEND_BUCKET)" \
		-backend-config="key=$(TF_BACKEND_KEY)" \
		-backend-config="region=$(AWS_REGION)"

plan:
	terraform plan -no-color -input=false

apply:
	terraform apply -auto-approve

validate:
	terraform init -backend=false
	terraform validate
