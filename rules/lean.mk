answer: Main.lean ../../input
	lean --run $< > $@

.PHONY: lint
lint:

.PHONY: clean
clean:
	rm -f answer
