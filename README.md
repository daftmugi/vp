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

* Ruby 3.0+
* Tested on Linux
* Not tested on Windows


## Installation

* Use `vp` as is or copy it somewhere included in the `PATH`.
* **NOTE:** `vp` can be renamed to something else if desired.


## Usage

```
Usage: vp -l VP_FILE [REGEX]        [-L]      [-v | -vv]
       vp -x VP_FILE [REGEX] -d DIR [-L] [-n]
       vp -p VP_FILE [REGEX]        [-L]
       vp -c VP_FILE         -d DIR [-L] [-n] [-v | -vv]
       vp -D [EXCLUDE_VPS]

Commands:
    -l VP_FILE    : list VP package files
    -x VP_FILE    : extract VP package
    -p VP_FILE    : extract VP package files to stdout (pipe)
    -c VP_FILE    : create VP package
    -D            : read VP packages and print duplicates
    -D help       : print more details about -D usage
    --help, -h    : print this message
    --version     : print version

Options:
    REGEX         : filter files by a regular expression
    EXCLUDE_VPS   : comma-separated VP set 'a,b,...' to exclude
    -d DIR        : create from/extract to directory
    -L            : convert filenames to lowercase
    -n            : no-op, dry-run
    -v            : verbose
    -vv           : verbose with extra info (very verbose)
    --debug       : print more on error
```


## Usage: Find Duplicates

```
Usage: vp -D [EXCLUDE_PAKS]

-D
    Finds duplicate file paths in VP packages of the current directory.
    This is useful for finding conflicting files.

EXCLUDE_VPS
    Comma-separated set of VPs to exclude, in the form 'a,b,...'.
    The VPs in the set do not need to include the '.vp' extension.

    A duplicate file prints only if there is at least one VP not
    included in the EXCLUDE_VPS set.

    Examples:
      vp0.vp -> data/a.txt
      vp1.vp -> data/a.txt
      vp1.vp -> data/b.txt
      vp2.vp -> data/b.txt
      vp2.vp -> data/c.txt
      vp3.vp -> data/c.txt

      $ vp -D
      data/a.txt: vp0.vp, vp1.vp
      data/b.txt: vp1.vp, vp2.vp
      data/c.txt: vp2.vp, vp3.vp

      $ vp -D vp0
      data/a.txt: vp0.vp, vp1.vp
      data/b.txt: vp1.vp, vp2.vp
      data/c.txt: vp2.vp, vp3.vp

      $ vp -D vp0,vp1
      data/b.txt: vp1.vp, vp2.vp
      data/c.txt: vp2.vp, vp3.vp

      $ vp -D vp1,vp2
      data/a.txt: vp0.vp, vp1.vp
      data/c.txt: vp2.vp, vp3.vp

      $ vp -D vp0,vp1,vp2
      data/c.txt: vp2.vp, vp3.vp

      $ vp -D vp0,vp1,vp2,vp3
      <no output>
```


## Thanks

Thanks to qazwsxal, taylor, Goober5000, and others on Discord for
discussions that helped with implementing the VP "spec" correctly.

There isn't an official "spec" per se. There is the FreeSpace Open
(FSO) codebase and personal projects along with the wiki page. Those
discussions were crucial in clarifying some nuances.
