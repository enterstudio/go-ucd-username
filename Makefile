CWD=$(shell pwd)
GOPATH := $(CWD)

prep:
	if test -d pkg; then rm -rf pkg; fi

self:   prep rmdeps
	if test -d src/github.com/thisisaaronland/go-ucd-username; then rm -rf src/github.com/thisisaaronland/go-ucd-username; fi
	mkdir -p src/github.com/thisisaaronland/go-ucd-username
	cp *.go src/github.com/thisisaaronland/go-ucd-username/
	cp -r http src/github.com/thisisaaronland/go-ucd-username/
	cp -r vendor/* src/

rmdeps:
	if test -d src; then rm -rf src; fi 

build:	fmt bin

deps:	rmdeps
	@GOPATH=$(GOPATH) go get -u "github.com/cooperhewitt/go-ucd"
	@GOPATH=$(GOPATH) go get -u "github.com/whosonfirst/go-sanitize"

vendor-deps: rmdeps deps
	if test ! -d vendor; then mkdir vendor; fi
	if test -d vendor; then rm -rf vendor; fi
	cp -r src vendor
	find vendor -name '.git' -print -type d -exec rm -rf {} +
	rm -rf src

fmt:
	go fmt *.go
	go fmt cmd/*.go
	go fmt http/*.go

bin: 	self
	@GOPATH=$(GOPATH) go build -o bin/ucd-username cmd/ucd-username.go
	@GOPATH=$(GOPATH) go build -o bin/ucd-usernamed cmd/ucd-usernamed.go

docker-build:
	docker build -t ucd-username .

docker-debug: docker-build
	docker run -it -p 6161:8080 -e HOST='0.0.0.0' ucd-username