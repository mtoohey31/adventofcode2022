answer: main.prolog ../../input
	swipl -g main -t halt $< > $@

.PHONY: lint
lint:

.PHONY: clean
clean:
	rm -f answer
