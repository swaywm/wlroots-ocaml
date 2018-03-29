EXAMPLES := simple
EXAMPLES := $(patsubst %,examples/%.exe,$(EXAMPLES))

default:
	jbuilder build @install

examples: $(EXAMPLES)

$(EXAMPLES):
	jbuilder build $@

clean:
	rm -rf _build

.PHONY: default clean examples
