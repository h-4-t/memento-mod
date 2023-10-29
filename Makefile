SHELL=sh
VERSION?=0.9.1
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all lint bump zip dist changelog changelog-current

all: help

## Lint:
lint: ## Lint the lua files
	docker run -v "${ROOT_DIR}:/data" -w /data ghcr.io/lunarmodules/luacheck:latest .

## Bump: 
bump: ## Bump version to environment variable
	sed -i 's/Memento.Version =.*/Memento.Version = "${VERSION}"/' ${ROOT_DIR}/main.lua
	sed -i "s|<version>.*|<version>${VERSION}</version>|" ${ROOT_DIR}/metadata.xml

## Zip:
zip: ## Package a zip for release
	cd ${ROOT_DIR}
	zip memento-${VERSION}.zip *.lua *.md resources metadata.xml LICENSE

## Dist
dist: ## Make a dist folder for steam workshop deploy
	cd ${ROOT_DIR}
	mkdir dist
	cp -r *.lua *.md resources metadata.xml LICENSE dist/

## Changelog Current
changelog-current: ## Generate the changelog for the current version
	docker run -v "${ROOT_DIR}:/workdir" quay.io/git-chglog/git-chglog --output CHANGELOG-${VERSION}.md ${VERSION}

## Changelog
changelog: ## Generate the complete changelog
	docker run -v "${ROOT_DIR}:/workdir" quay.io/git-chglog/git-chglog --output CHANGELOG.md
## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

swag:
	swag init