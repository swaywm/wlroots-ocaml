EXAMPLES := simple
EXAMPLES := $(patsubst %,examples/%.exe,$(EXAMPLES))

default:
	dune build @install

examples:
	dune build @examples

clean:
	rm -rf _build

.PHONY: default clean examples
