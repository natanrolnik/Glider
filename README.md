# Glider
### A view to play Core Animation Archive (.caar) files

A **Core Animation Archive** is a file that encodes, via `NSKeyedArchive`, a `CALayer` hierarchy and its animations. You can generate it programatically on iOS and macOS, or with the insanely intuitive and powerful [Kite](https://kiteapp.co).

**Glider** is an extremely thin and light set of types that:
* takes care of loading a `CALayer` from a `.caar` file (either locally or from a remote server)
* renders its contents in a `UIView`,
* gives simple control over the animation, like playing, pausing, stopping, looping, and completion.

Check the playgrounds to see an example of how to use it.

## Usage

## Installation
* CocoaPods (To Do)
* Carthage (To Do)
* Submodule
* Drag and drop

## Features/Roadmap:
- [x] Load remote file
- [x] Play, pause and stop
- [x] Repeat count and looping
- [x] Objective-C support
- [x] Completion block
- [ ] Caching
- [ ] Play backwards (boomerang style)
- [ ] macOS support
