answer: default.nix ../../input ../../../nix/lib.nix
	nix eval --raw --file $< > $@

.PHONY: lint
lint: default.nix ../../../nix/lib.nix
	deadnix --fail $^
	nixpkgs-fmt --check $^

.PHONY: clean
clean:
	rm -f answer
