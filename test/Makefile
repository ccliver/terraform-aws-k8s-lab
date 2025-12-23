.DEFAULT_GOAL := help

init: ## Initialize the module
	go mod init github.com/ccliver/teraform-aws-k8s-lab
	go mod tidy

test: ## Run the tests
	go test -v -timeout 45m

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
