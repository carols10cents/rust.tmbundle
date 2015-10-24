# Rust TextMate2 Bundle

A TextMate Bundle for the Rust programming langauage.

## Installation

Without any extra dependencies:

* Download either the zip or tar
* Decompress
* Rename the subdirectory rust_tmbundle to rust.tmbundle
* Double click on rust.tmbundle to install in TextMate

If you'd like, and assuming you don't mind using Ruby, you can use the ruby gem
`tmbundle-manager` to makes managing and updating yourtextmate bundles easier:

### Initial installation

```bash
gem install tmbundle-manager
tmb install carols10cents/rust
```

### Updating

```bash
tmb update rust
```

## Current Features:

- Basic Syntax Highlighting
- Code Snippets
- Commands **(Note the cargo commands will only work in TextMate Nightly until https://github.com/textmate/textmate/pull/1305 is released)**:

<table>
  <tr>
    <th>In order to:</th>
    <th>Shortcut:</th>
  </tr>
  <tr>
    <td>Build current file</td>
    <td>cmd + b</td>
  </tr>
  <tr>
    <td>Build current file with tests</td>
    <td>cmd + shift + b</td>
  </tr>
  <tr>
    <td>Run current file</td>
    <td>cmd + r</td>
  </tr>
  <tr>
    <td>Run current file with tests</td>
    <td>cmd + shift + r</td>
  </tr>
  <tr>
    <th colspan="2">
      When a `Cargo.toml` is present in the root:
    </th>
  </tr>
  <tr>
    <td>Cargo build current project</td>
    <td>cmd + b</td>
  </tr>
  <tr>
    <td>Cargo run current project</td>
    <td>cmd + r</td>
  </tr>
  <tr>
    <td>Cargo test current project</td>
    <td>cmd + shift + r</td>
  </tr>
</table>

- Autocompletion when racer is available (see instructions below)

## How to enable autocompletion via racer

- Install racer by following [the instructions in racer's README](https://github.com/phildawes/racer)
- The textmate bundle will look in the following locations first for a `racer` binary, so either move or symlink `[racer checkout directory]/target/release/racer` into one of these locations:
  - `/usr/local/bin`
  - `/opt/local/bin`
  - `$CARGO_INSTALL_ROOT/bin` (if you have set `CARGO_INSTALL_ROOT` in TextMate)
  - `$CARGO_HOME/bin`  (if you have set `CARGO_HOME` in TextMate)
  - `$HOME/.cargo/bin`
- If you want your `racer` binary to be somewhere other than the locations in the last step, set the `TM_RACER` variable in your TextMate preferences to the location of your `racer` binary.
- Set the `RUST_SRC_PATH` variable in your TextMate preferences to the location of your Rust source directory (the same location that you set this variable to as part of the racer installation instructions).

## Future Features:

- Improved Syntax Highlighting
- Block folding of functions
- File an issue if you have more ideas!

## License

This bundle is licensed under the MIT License (LICENSE).

* Copyright (c) 2012 [Tom Ellis](http://www.webmuse.co.uk/)
* Copyright (c) 2014 [Elia Schito](http://elia.schito.me/)
* Copyright (c) 2015 [Carol (Nichols || Goulding)](http://carol-nichols.com)
