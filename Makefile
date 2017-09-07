all: build

subdirs = py src central

include common.mk

CORE_IMG = $(ROOT_DIR)/core.img

CORE_ME = $(MM_DIR)/stdlib/core.me

build:
	$(foreach el,$(subdirs),$(MAKE) -C $(el) all;)

clean:
	$(foreach el,$(subdirs),$(MAKE) -C $(el) clean;)

debug:
	$(foreach el,$(subdirs),$(MAKE) -C $(el) debug;)

test: build; $(MAKE) -C $(MM_DIR)/tests $@

src: core

core: $(CORE_IMG)

$(CORE_IMG):
	cd $(PY_DIR); python -m pycore.compiler $(CORE_ME) $(ROOT_DIR)

.PHONY: $(subdirs) clean
