.DEFAULT_GOAL := help
.PHONE: do-test

do-build-test: ## Deploy the scripts and files to an exist digital ocean server
	cd fabric && fab build_test -H ${DO_SERVER_IP}

do-build-image: ## Build image but without creating snapshot to an exist digital ocean server
	cd fabric && fab build_image -H ${DO_SERVER_IP}

do-build-image-snapshot: ## Build image create snapshot to digital ocean from scratch. `DIGITALOCEAN_TOKEN` environment variable is required.
	cd packer && packer build marketplace-image.json

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
