answer: default.nix ../../input
	nix eval --raw --file $< > $@

.PHONY: clean
clean:
	rm -f answer
