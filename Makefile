name ?= nebula-console

# build with verison infos
buildDate = $(shell TZ=UTC date +%FT%T%z)
gitCommit = $(shell git log --pretty=format:'%h' -1)

ldflags="-w -X main.gitTag=${gitTag} -X main.buildDate=${buildDate} -X main.gitCommit=${gitCommit}"

.PHONY: build vendorbuild clean fmt gen

default: build

build: clean gen fmt
	@CGO_ENABLED=0 go build -o ${name} -ldflags ${ldflags}

vendorbuild: clean gen fmt
	@CGO_ENABLED=0 go mod vendor && go build -mod vendor -o ${name} --tags netgo -ldflags ${ldflags}

clean:
	@rm -rf ${name} vendor

fmt:
	@go mod tidy && find . -path vendor -prune -o -type f -iname '*.go' -exec go fmt {} \;

# generate box/blob.go
gen:
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go generate ./...
