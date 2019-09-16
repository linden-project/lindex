OUT_DIR=bin

all: build

build:
	@echo "Building wimpix in $(shell pwd)"
	@mkdir -p $(OUT_DIR)
	@crystal build -o $(OUT_DIR)/wimpix src/wimpix.cr

run:
	$(OUT_DIR)/wimpix

clean:
	rm -rf  bin/wimpix* docs tmp *.dwarf *.tmp

clean_all:
	rm -rf  $(OUT_DIR) .crystal .shards lib docs tmp *.dwarf *.tmp

#link:
#	@ln -s `pwd`/bin/wimpix /usr/local/bin/wimpix
#
#force_link:
#	@echo "Symlinking `pwd`/bin/wimpix to /usr/local/bin/wimpix"
#	@ln -sf `pwd`/bin/wimpix /usr/local/bin/wimpix

run_coverage:
	@bin/crystal-coverage spec/spec_all.cr

run_spec:
	@crystal spec

release:
	@echo "you should execute: crelease x.x.x"
