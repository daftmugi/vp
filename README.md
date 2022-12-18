# VP.rb

**VP.rb** is a VP (**V**olition **P**ackage) packer/unpacker for FreeSpace.

See [*.VP on the FreeSpace Wiki](https://wiki.hard-light.net/index.php/*.VP).


## Features

* Commands
    - List VP package files.
    - Extract VP package files.
    - Extract VP package files to stdout; pipe files.
    - Create VP package.
* All commands support converting files to lowercase filenames.
* All commands, except create, support regular expression filtering.
* Extract and create commands have a no-op/dry-run mode.
* List and create commands have verbose and very verbose modes.


## Usage

* See `vp --help`.


## Requirements

* Ruby 3.0+
* Tested on Linux
* Not tested on Windows


## Installation

* Use `vp` as is or copy it somewhere included in the `PATH`.
* **NOTE:** `vp` can be renamed to something else if desired.
