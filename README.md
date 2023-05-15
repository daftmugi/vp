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

```
Usage: vp -l VP_FILE [-m REGEX]        [-L]      [-v | -vv]
       vp -x VP_FILE [-m REGEX] -d DIR [-L] [-n]
       vp -p VP_FILE [-m REGEX]        [-L]
       vp -c VP_FILE            -d DIR [-L] [-n] [-v | -vv]
       vp -D [PATHS] [-m REGEX] [--checksum] [-e EXCLUDE_VPS]

Commands:
    -l VP_FILE     : list VP package files
    -x VP_FILE     : extract VP package
    -p VP_FILE     : extract VP package files to stdout (pipe)
    -c VP_FILE     : create VP package
    -D             : read VP packages and print duplicates
    -D help        : print more details about -D usage
    --help, -h     : print this message
    --version      : print version

Options:
    -m REGEX       : match file paths by a regular expression
    -d DIR         : create from/extract to directory
    -L             : convert filenames to lowercase
    -n             : no-op, dry-run
    -v             : verbose
    -vv            : verbose with extra info (very verbose)
    --debug        : more detailed error messages
```


## Usage: Find Duplicates

```
Usage: vp -D [PATHS] [-m REGEX] [--checksum] [-e EXCLUDE_VPS]

-D [PATHS]
    Find duplicates in VP packages based on FSO loading rules.
    This is useful for finding conflicting files.
    Path Type:
        A path starting from a 'data/' sub-directory.
        For example: 'data/effects', 'data/maps'.
    Duplicate Types:
        "override" -> same path type, same filename, same sub-path.
          "shadow" -> same path type, same filename, different sub-path.

    PATHS
        Comma-separated list of paths to search for '.vp' files.
        When PATHS is omitted, the current directory is searched for '.vp' files.
        For example:
            "-D" -> search current directory './'
            "-D mod1" -> from current directory, search './mod1'
            "-D mod1,mod2,mod3" -> search './mod1', './mod2', './mod3'
            "-D mod1,mod2,." -> search './mod1', './mod2', './'
              NOTE: './' is the current directory. Good for including FS2 retail vp files.

    Output Column Labels:

       Type     Priority VP ::      File       :: List of Overridden VP
    ----------  -----------    ---------------    -------------------------
    [override]  mod1/vp1.vp :: data/maps/a.dds :: mod2/vp2.vp
    [override]  mod1/vp1.vp :: data/maps/b.dds :: mod2/vp2.vp, mods4/vp4.vp


       Type     Priority VP ::      File       <>      Shadowed By      :: List of Overridden VP
    ----------  -----------    ---------------    ---------------------    -------------------------
    [shadow]    mod1/vp1.vp :: data/maps/a.dds <> data/maps/other/a.dds :: mod2/vp2.vp
    [shadow]    mod1/vp1.vp :: data/maps/b.dds <> data/maps/other/b.dds :: mod2/vp2.vp, mods4/vp4.vp



-m REGEX
    Match file paths by a regular expression.
    For example:
        "-m 'dds'" -> match names that include 'dds'
        "-m '\.dds$'" -> match names that end with '.dds'
        "-m 'data/effects/.*'" -> match path type 'effects'


--checksum
    Use CRC32 checksum-based file matching.
    When a file matches on both 'path type' and 'filename',
    duplicates are determined by their checksums.

    Output Column Labels:

        Type      Priority File :: List of Matching VP[:Shadow File Path] Files
    ------------  -------------    --------------------------------------------
    [identical]      data/a.txt :: mod1/vp1.vp, mod4/vp4.vp
    [identical]      data/b.txt :: mod1/vp1.vp, mod2/vp2.vp:data/other/b.txt


-e EXCLUDE_VPS
    Comma-separated set of VPs to exclude, in the form 'a,b,...'.
    The VPs in the set do not need to include the '.vp' extension.

    A duplicate file prints only if there is at least one VP not included
    in the EXCLUDE_VPS set. NOTE: There may be a duplicate file printed
    with just the EXCLUDE_VPS set, because the total duplicate set may be
    spread across multiple output lines of "override" and "shadow" types.

    Examples:
      vp0.vp -> data/a.txt
      vp1.vp -> data/a.txt
      vp1.vp -> data/b.txt
      vp2.vp -> data/b.txt
      vp2.vp -> data/c.txt
      vp3.vp -> data/c.txt

      $ vp -D
      [override]  vp0.vp :: data/a.txt :: vp1.vp
      [override]  vp1.vp :: data/b.txt :: vp2.vp
      [override]  vp2.vp :: data/c.txt :: vp3.vp

      $ vp -D -e vp0
      [override]  vp0.vp :: data/a.txt :: vp1.vp
      [override]  vp1.vp :: data/b.txt :: vp2.vp
      [override]  vp2.vp :: data/c.txt :: vp3.vp

      $ vp -D -e vp0,vp1
      [override]  vp1.vp :: data/b.txt :: vp2.vp
      [override]  vp2.vp :: data/c.txt :: vp3.vp

      $ vp -D -e vp1,vp2
      [override]  vp0.vp :: data/a.txt :: vp1.vp
      [override]  vp2.vp :: data/c.txt :: vp3.vp

      $ vp -D -e vp0,vp1,vp2
      [override]  vp2.vp :: data/c.txt :: vp3.vp

      $ vp -D -e vp0,vp1,vp2,vp3
      <no output>
```


## Thanks

Thanks to qazwsxal, taylor, Goober5000, and others on Discord for
discussions that helped with implementing the VP "spec" correctly.

There isn't an official "spec" per se. There is the FreeSpace Open
(FSO) codebase and personal projects along with the wiki page. Those
discussions were crucial in clarifying some nuances.
