all: build

include $(shell git rev-parse --show-toplevel)/common.mk

$(call GEN_MEC_RULE)


CODE := io.me qt.me remote_repl.me
BYTECODE := $(patsubst %.me,%.mec,$(CODE))


build: $(BYTECODE)
clean:; -rm $(BYTECODE)
