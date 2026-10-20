# Deploy NixOS configurations to PSA VMs
# Usage:
#   make deploy-01   - deploy to VM 01 (port 60922)
#   make deploy-02   - deploy to VM 02 (port 60923)
#   make deploy-all  - deploy to all VMs

HOST ?= psa.in.tum.de
BASE_PORT := 60921
VMS := 01 02

define deploy_vm
deploy-$(1):
	NIX_SSHOPTS="-p $(shell expr $(BASE_PORT) + $(1))" nixos-rebuild --target-host $(USER)@$(HOST) --sudo --flake .#vmpsateam09-$(1) switch --ask-sudo-password
endef

$(foreach vm,$(VMS),$(eval $(call deploy_vm,$(vm))))

deploy-all: $(addprefix deploy-,$(VMS))

.PHONY: deploy-all $(addprefix deploy-,$(VMS))
