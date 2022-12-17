answer: Cargo.toml Cargo.lock src/main.rs ../../input
	cargo run > $@

.PHONY: lint
lint:

.PHONY: clean
clean:
	rm -rf answer target
