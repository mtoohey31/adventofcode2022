answer: main ../../input
	./$< > $@

main: main.o $(EXTRA_OBJS)
	$(CC) -Wall -o $@ $^

.PHONY: lint
lint:

.PHONY: clean
clean:
	rm -f answer main *.o
