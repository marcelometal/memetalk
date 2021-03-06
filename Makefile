subdirs = py src central

include common.mk

CORE_IMG = $(ROOT_DIR)/core.img

CORE_ME = $(MM_DIR)/stdlib/core.me

all:
	$(foreach el,$(subdirs),$(MAKE) -C $(el) all;)

clean:
	$(MAKE) -C src clean

debug:
	$(MAKE) -C src debug

test:; $(MAKE) -C $(MM_DIR)/tests $@

src: core

core: $(CORE_IMG)

cleanall:
	$(foreach el,$(subdirs),$(MAKE) -C $(el) clean;)

$(CORE_IMG):
	cd $(PY_DIR); python -m pycore.compiler $(CORE_ME) $(ROOT_DIR)

.PHONY: $(subdirs) clean
