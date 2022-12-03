answer: main.go ../../input
	go run $< > $@

.PHONY: clean
clean:
	rm -f answer
