EXAMPLES := simple
EXAMPLES := $(patsubst %,examples/%.exe,$(EXAMPLES))

default:
	dune build @install

examples: $(EXAMPLES)

$(EXAMPLES):
	dune build $@

clean:
	rm -rf _build

.PHONY: default clean examples
