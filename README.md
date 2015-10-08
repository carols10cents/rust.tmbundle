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
- Commands:

<table>
  <tr>
    <th>In order to:</th>
    <th>Shortcut:</th>
  </tr>
  <tr>
    <td>Compile current file</td>
    <td>cmd + shift + c</td>
  </tr>
  <tr>
    <td>Compile current file with tests</td>
    <td>cmd + shift + a</td>
  </tr>
  <tr>
    <td>Compile and run current file</td>
    <td>cmd + r</td>
  </tr>
  <tr>
    <td>Compile with tests and run the tests</td>
    <td>cmd + option + shift + r</td>
  </tr>
  <tr>
    <td>Cargo build current project</td>
    <td>cmd + shift + b</td>
  </tr>
  <tr>
    <td>Cargo run current project</td>
    <td>cmd + shift + r</td>
  </tr>
  <tr>
    <td>Cargo test current project</td>
    <td>option + shift + r</td>
  </tr>
</table>

## Future Features:

- Improved Syntax Highlighting
- Block folding of functions
- File an issue if you have more ideas!

## License

This bundle is licensed under the MIT License (LICENSE).

* Copyright (c) 2012 [Tom Ellis](http://www.webmuse.co.uk/)
* Copyright (c) 2014 [Elia Schito](http://elia.schito.me/)
* Copyright (c) 2015 [Carol (Nichols || Goulding)](http://carol-nichols.com)
