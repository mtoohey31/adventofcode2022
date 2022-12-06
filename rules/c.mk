answer: main ../../input
	./$< > $@

main: main.o
	$(CC) -Wall -o $@ $^

.PHONY: lint
lint:

.PHONY: clean
clean:
	rm -f answer main *.o
