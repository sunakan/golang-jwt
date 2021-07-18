.PHONY: bash
bash: ## コンテナにbashで入る
	docker-compose run --rm --service-ports app bash

.PHONY: up
up: air ## ホットリロードでWebサーバーを起動
	docker-compose run --rm --service-ports app air

.PHONY: resolve-dependencies
resolve-dependencies: ## 利用パッケージを入れたり、未利用パッケージを削除する
	docker-compose run --rm app go mod tidy

.PHONY: air
air: ## Goでホットリロードを実現するairのインストール
	docker-compose run --rm app bash -c 'air -v || go install github.com/cosmtrek/air@latest'

.PHONY: clean
clean: ## docker volumeを含めた掃除
	docker-compose down --volume

.PHONY: curl
curl: ## curlでお試し
	$(eval JWT_TOKEN := $(shell curl -s localhost:8080/auth))
	@echo "==================TOKEN 無し"
	curl -is localhost:8080/private-ping
	@echo "==================TOKEN 有り"
	curl -is localhost:8080/private-ping -H 'Authorization: Bearer $(JWT_TOKEN)'

################################################################################
# Utility-Command help
################################################################################
.DEFAULT_GOAL := help

################################################################################
# マクロ
################################################################################
# Makefileの中身を抽出してhelpとして1行で出す
# $(1): Makefile名
define help
  grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) \
  | grep --invert-match "## non-help" \
  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
endef
################################################################################
# タスク
################################################################################
.PHONY: help
help: ## Make タスク一覧
	@echo '######################################################################'
	@echo '# Makeタスク一覧'
	@echo '# $$ make XXX'
	@echo '# or'
	@echo '# $$ make XXX --dry-run'
	@echo '######################################################################'
	@echo $(MAKEFILE_LIST) \
	| tr ' ' '\n' \
	| xargs -I {included-makefile} $(call help,{included-makefile})
