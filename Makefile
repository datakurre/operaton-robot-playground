help:
	@grep -Eh '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | uniq

INDEX_URL ?= https://pypi.python.org/simple
INDEX_HOSTNAME ?= pypi.python.org

export PYTHONPATH=$(PWD)/src

env:  ## Build and link the Python virtual environment
	ln -s $(shell devenv build outputs.python.virtualenv) env

clean:  ## Remove build artifacts and temporary files
	devenv gc

devenv-up:  ## Start background services
	devenv processes up -d

devenv-attach:  ## Attach to background services monitor
	devenv shell -- process-compose attach

devenv-down:  ## Stop background services
	devenv processes down

devenv-test: ## Run all test and checks with background services
	devenv test

format:  ## Format the codebase
	treefmt

shell:  ## Start an interactive development shell
	@devenv shell

show:  ## Show build environment information
	@devenv info

###

define _env_script
cat << EOF > .env
ENGINE_REST_BASE_URL="http://localhost:8080/engine-rest"
ENGINE_REST_AUTHORIZATION="Basic ZGVtbzpkZW1v"
EOF
endef
export env_script = $(value _env_script)
.env: ; @ eval "$$env_script"

devenv-%:  ## Run command in devenv shell
	devenv shell -- $(MAKE) $*

nix-%:  ## Run command in devenv shell
	devenv shell -- $(MAKE) $*

FORCE:
