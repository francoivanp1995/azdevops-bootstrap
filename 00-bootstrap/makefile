SCRIPT_DIR=00-script
TF_DIR=10-terraform
BACKEND_CONFIG=../.azure.conf
VAR_FILE=../project-name.json

bootstrap:
	@echo "Ejecutando script de creación bootstrap..."
	bash $(SCRIPT_DIR)/create.sh

init:
	@echo "Inicializando Terraform con backend config..."
	cd $(TF_DIR) && terraform init -backend-config=$(BACKEND_CONFIG)

apply: init
	@echo "Aplicando Terraform con var-file..."
	cd $(TF_DIR) && terraform apply -var-file=$(VAR_FILE) -auto-approve

destroy:
	@echo "Destruyendo infraestructura con Terraform..."
	cd $(TF_DIR) && terraform destroy -var-file=$(VAR_FILE) -auto-approve

clean:
	@echo "Ejecutando script de borrado bootstrap..."
	bash $(SCRIPT_DIR)/delete.sh
