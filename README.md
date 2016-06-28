# elpa-clone - Clone ELPA archive

*Author:* ZHANG Weiyi <dochang@gmail.com><br>
*Version:* 0.0.1<br>
*URL:* [https://github.com/dochang/elpa-clone](https://github.com/dochang/elpa-clone)<br>

Mirror an ELPA archive into a directory.

## Prerequisites

  - Emacs 24.4 or later
  - cl-lib

## Installation

To install `elpa-clone` from git repository, clone the repo, then add the
repo dir into `load-path`.

## Usage

To clone an ELPA archive `http://host/elpa` into `/path/to/elpa`, invoke
`elpa-clone`:

        (elpa-clone "http://host/elpa" "/path/to/elpa")

`elpa-clone` can also be invoked via <kbd>M-x</kbd>.

## Note

`elpa-clone` does NOT overwrite existing files.  If a package file is
broken, remove the file and call `elpa-clone` again.

## License

GPLv3


---
Converted from `elpa-clone.el` by [*el2markdown*](https://github.com/Lindydancer/el2markdown).
