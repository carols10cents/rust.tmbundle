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
- Command to compile (using: rustc source.rs) (cmd+shift+c)
- Command to compile with tests (using: rustc --test source.rs) (cmd+shift+a)
- Run command. Runs compiled Rust file. If file hasn't been compiled it will compile it first. (cmd+r)
- Code Snippets

## Future Features:

- Improved Syntax Highlighting
- Block folding of functions
- `cargo` integration
- File an issue if you have more ideas!

## License

This bundle is licensed under the MIT License (LICENSE).

* Copyright (c) 2012 [Tom Ellis](http://www.webmuse.co.uk/)
* Copyright (c) 2014 [Elia Schito](http://elia.schito.me/)
* Copyright (c) 2015 [Carol (Nichols || Goulding)](http://carol-nichols.com)
