answer: main.nim ../../input
	nim r $< > $@

.PHONY: lint
lint:

.PHONY: clean
clean:
	rm -f answer
