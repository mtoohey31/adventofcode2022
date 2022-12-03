answer: main.go ../../input
	go run $< > $@

.PHONY: lint
lint:
	export FILES="$$(gofmt -l .)"; echo "$$FILES"; test -z "$$FILES"

.PHONY: clean
clean:
	rm -f answer
