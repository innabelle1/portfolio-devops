SERVICES = config-server discovery-server customers-service visits-service vets-service genai-service api-gateway admin-server
NAMESPACE = petclinic

deploy-all:
	@for svc in $(SERVICES); do \
		helm upgrade --install $$svc ./$$svc --namespace $(NAMESPACE) --create-namespace; \
	done

delete-all:
	@for svc in $(SERVICES); do \
		helm uninstall $$svc --namespace $(NAMESPACE); \
	done

lint-all:
	@for svc in $(SERVICES); do \
		helm lint ./$$svc; \
	done
