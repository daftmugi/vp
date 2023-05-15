# VP.rb

**VP.rb** is a command-line VP (**V**olition **P**ackage) packer/unpacker for FreeSpace.

See [*.VP on the FreeSpace Wiki](https://wiki.hard-light.net/index.php/*.VP).


## Features

* Commands
    - List VP package files.
    - Extract VP package files.
    - Extract VP package files to stdout; pipe files.
    - Create VP package.
    - Find duplicate file paths in VP packages.
* All commands support converting files to lowercase filenames.
* All commands, except create, support regular expression filtering.
* Extract and create commands have a no-op/dry-run mode.
* List and create commands have verbose and very verbose modes.


## Requirements

* [Ruby 3.0+](https://www.ruby-lang.org/en/downloads/)
* Linux
    - Ubuntu: `apt install ruby`
* Windows
    - [RubyInstaller](https://rubyinstaller.org/downloads/) 3.0 builds are known to work.
        + [Ruby+Devkit 3.0.6-1 (x64)](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.0.6-1/rubyinstaller-devkit-3.0.6-1-x64.exe)
        + [Ruby 3.0.6-1 (x64)](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.0.6-1/rubyinstaller-3.0.6-1-x64.exe)
    - "MSYS2 development toolchain" is not required.
    - "ridk install" is not required.
    - **NOTE:** As of this writing, RubyInstaller 3.1 and 3.2 builds are not compatible,
      since the program may not run due to an error with the message
      ["unexpected ucrtbase.dll"](https://github.com/oneclick/rubyinstaller2/issues/308).


## Installation

* `vp` is in the `bin/` directory.
* Use `vp` as is or copy it somewhere included in the `PATH`.
* **NOTE:** `vp` can be renamed to something else if desired.
* **NOTE:** Windows users may need to prepend `ruby` to `vp` to
  run it. For example, `ruby vp`.


## Usage

`USAGE_BLOCK`


## Usage: Find Duplicates

`FIND_DUPLICATES_USAGE_BLOCK`


## Thanks

Thanks to qazwsxal, taylor, Goober5000, and others on Discord for
discussions that helped with implementing the VP "spec" correctly.

There isn't an official "spec" per se. There is the FreeSpace Open
(FSO) codebase and personal projects along with the wiki page. Those
discussions were crucial in clarifying some nuances.
