
build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build main.go
	zip my-lambda-function.zip main

verify:
	terraform validate

format:
	terraform fmt
	go fmt