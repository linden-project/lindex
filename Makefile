OUT_DIR=bin

all: build

build:
	@echo "Building lindex in $(shell pwd)"
	@mkdir -p $(OUT_DIR)
	@crystal build -o $(OUT_DIR)/lindex src/lindex.cr

run:
	$(OUT_DIR)/lindex

clean:
	rm -rf  bin/lindex* docs tmp *.dwarf *.tmp

clean_all:
	rm -rf  $(OUT_DIR) .crystal .shards lib docs tmp *.dwarf *.tmp coverage

run_coverage:
	@bin/crystal-coverage spec/spec_all.cr

run_spec:
	@crystal spec

release:
	@echo "you should execute: crelease x.x.x"
