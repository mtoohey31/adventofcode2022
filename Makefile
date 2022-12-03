.PHONY: all
all:

.PHONY: clean
clean::

define ANSWER_template =
all: $(1)/answer

.PHONY: $(1)/answer
$(1)/answer: $(1)/../.envrc
	cd $(1); nix develop ../../..#$(shell grep -oP '(?<=^use flake \.\./\.\.#).*' $(1)/../.envrc) -ic make answer

clean::
	cd $(1); make clean
endef

$(foreach part,$(foreach lang,$(foreach day,$(wildcard day??),$(wildcard $(day)/*)),$(wildcard $(lang)/part?)),$(eval $(call ANSWER_template,$(part))))
