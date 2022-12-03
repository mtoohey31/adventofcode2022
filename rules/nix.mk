answer: default.nix ../../input ../../../nix/lib.nix
	nix eval --raw --file $< > $@

.PHONY: clean
clean:
	rm -f answer
