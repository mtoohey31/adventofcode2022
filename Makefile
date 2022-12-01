.PHONY: all
all:

.PHONY: clean
clean::

define ANSWER_template =
all: $(1)/answer

.PHONY: $(1)/answer
$(1)/answer:
	cd $(1); make answer

clean::
	cd $(1); make clean
endef

$(foreach part,$(foreach day,$(wildcard day??),$(wildcard $(day)/part?)),$(eval $(call ANSWER_template,$(part))))
