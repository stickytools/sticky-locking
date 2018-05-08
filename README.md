# StickyLocking ![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-lightgray.svg?style=flat)

<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
   <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms: iOS | macOS | watchOS | tvOS | Linux" />
</a>
<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
   <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
</a>
<a href="https://travis-ci.org/stickytools/sticky-locking" target="_blank">
  <img src="https://travis-ci.org/stickytools/sticky-locking.svg?branch=master" alt="travis-ci.org" />
</a>
<a href="https://codecov.io/gh/stickytools/sticky-locking" target="_blank">
  <img src="https://codecov.io/gh/stickytools/sticky-locking/branch/master/graph/badge.svg" alt="Codecov" />
</a>
<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
    <img src="https://img.shields.io/cocoapods/v/StickyLocking.svg?style=flat" alt="Pod version">
</a>
<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
    <img src="https://img.shields.io/cocoapods/dt/StickyLocking.svg?style=flat" alt="Downloads">
</a>

## Overview

**StickyLocking** A general purpose embedded hierarchical lock manager used to build highly concurrent applications of all types.

Sticky Locking provides the `Locker` class which is a high-level locking system designed to facilitate many different 
concurrency use cases including simple readers-writer locks which provide shared access for read operations and 
exclusive access for write operations to more complex hierarchical locking schemes used to power database file, 
database, page, and row level locking.

The `Locker` is highly configurable to your specific use case using three interconnected constructs.

1) The `LockMode` defines the symbols your application will use to specify the lock modes various resources can be locked in.
2) The `CompatibilityMatrix` defines whether two modes can be granted concurrently for the same resource (is it shared or exclusive).
3) The `GroupModeMatrix` defines the composite mode a group of granted locks take on when granted together.

Sticky has two built-in sets of these values in the following enums.

`SharedExclusiveLockMode` which is a simple readers-writer system used to provide shared read access and exclusive 
write access.

An example use case for this mode may be to protect access to a file or many files which require all readers to be able
to share access to the file and writers to be granted exclusive access forcing readers and writers to wait until the
write operation is complete before they proceed.

In the following diagram shows 4 reader thread granted read access to the file resource.
![Readers-writer Lock Example - Readers Granted](Documentation/StickyLocking%20-%20Readers-writer%20Mode%20Diagrams%20-%20Readers%20Granted.png)

Once all readers unlock the resource, or the writer was first to request, the writer will be granted access forcing readers and other writers to wait.
![Readers-writer Lock Example - Writer Granted](Documentation/StickyLocking%20-%20Readers-writer%20Mode%20Diagrams%20-%20Writer%20Granted.png)

`ExtendedLockMode` an extended mode that includes intention and update modes which can be used for advanced database 
type use cases.  This LockMode set was designed to be used by other models in the Sticky Tools suite of libraries.

You are free to define your own LockMode set depending on your use case, from simpler mode structures to more complex,
Sticky Locking will adapt to the mode given.

## Sources and Binaries

You can find the latest sources and binaries on [github](https://github.com/stickytools/sticky-locking).

## Communication and Contributions

- If you **found a bug**, _and can provide steps to reliably reproduce it_, [open an issue](https://github.com/stickytools/sticky-locking/issues).
- If you **have a feature request**, [open an issue](https://github.com/stickytools/sticky-locking/issues).
- If you **want to contribute**
   - Fork it! [StickyLocking repository](https://github.com/stickytools/sticky-locking)
   - Create your feature branch: `git checkout -b my-new-feature`
   - Commit your changes: `git commit -am 'Add some feature'`
   - Push to the branch: `git push origin my-new-feature`
   - Submit a pull request :-)

## Installation 

**StickyLocking** supports dependency management via Swift Package Manager on All Apple OS variants as well as Linux.

Please see [Swift Package Manager](https://swift.org/package-manager/#conceptual-overview) for further information.

## Minimum Requirements

Build Environment

| Platform | Swift | Swift Build | Xcode |
|:--------:|:-----:|:----------:|:------:|
| Linux    | 4.0 | &#x2714; | &#x2718; |
| OSX      | 4.0 | &#x2714; | Xcode 9.0 |

Minimum Runtime Version

| iOS |  OS X | tvOS | watchOS | Linux |
|:---:|:-----:|:----:|:-------:|:------------:|
| 8.0 | 10.10 | 9.0  |   2.0   | Ubuntu 14.04, 16.04, 16.10 |

> **Note:**
>
> To build and run on **Linux** we have a a preconfigure **Vagrant** file located at [https://github.com/tonystone/vagrant-swift](https://github.com/stickytools/vagrant-swift)
>
> See the [README](https://github.com/tonystone/vagrant-swift/blob/master/README.md) for instructions.
>

## Author

Tony Stone ([https://github.com/tonystone](https://github.com/tonystone))

## License

StickyLocking is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
