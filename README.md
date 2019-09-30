# Lindex, a markdown document database indexer

[![GitHub release](https://img.shields.io/github/release/mipmip/lindex.svg)](https://github.com/mipmip/lindex/releases)
[![Build Status](https://travis-ci.org/mipmip/lindex.svg?branch=master)](https://travis-ci.org/mipmip/lindex)

Lindex is an indexer for the [Linden Notes standard](https://github.com/mipmip/linden-spec). Use Lindex together with the vim plugin [Linny.vim](https://github.com/mipmip/linny.vim).

Lindex is written in Crystal. It's fast.

## Features

- Implements all features of [Linden Notes 0.0.1](https://github.com/mipmip/linden-spec)
- Tested on Linux and macOS Mojave

## Installation

### With Homebrew

1. brew tap mipmip/homebrew-crystal
1. brew install lindex

### From Source

1. git clone https://github.com/mipmip/lindex
1. cd lindex
1. shards
1. make build

### Configuration

Make sure all files and directories exist.

Edit ~/.lindex.yml

```
---
root_path: ~/Dropbox/LinnyRoot
index_files_path: ~/.linny/index_files
```

Root_path is the folder containing ````/wiki```` with all Linny-markdown-files
and ````/config```` with all linny-l2 and linny-l3 config-files.

## Usage

run ````lindex make```` to create index. Run ````lindex make -c /path/to/different/config/lindex.yml

```
  lindex - Linny Indexer

  Usage:
    lindex [command] [arguments]

  Commands:
    help [command]  # Help about any command.
    make            # create index
    version         # show version

  Flags:
    -h, --help  # Help for this command. default: 'false'.
```

## Development

### Run Specs

```
make run_spec
make run_coverage
```

### Build

```
make build
```


## Contributing

1. Fork it (<https://github.com/mipmip/lindex/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Pim Snel](https://github.com/mipmip) - creator and maintainer
