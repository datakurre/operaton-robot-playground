help:
	@grep -Eh '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | uniq

env:
	ln -s $(shell devenv build outputs.python.virtualenv) env

clean:
	devenv gc
	$(RM) -r .venv .devenv*

devenv-up:
	devenv processes up -d

devenv-attach:
	devenv shell -- process-compose attach

devenv-down:
	devenv processes down

devenv-test:
	devenv test

format:
	treefmt

shell:  ## Enter development shell
	devenv shell

show:
	devenv info

start: devenv-up  ## Start background services

start-monitor: devenv-attach  ## Open process monitor

stop: devenv-down  ## Stop background services

watch-docs:
	LC_ALL=C make -C docs nix-watch

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
