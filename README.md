# StickyLocking ![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-lightgray.svg?style=flat)

<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
   <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms: iOS | macOS | watchOS | tvOS | Linux" />
</a>
<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
   <img src="https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat" alt="Swift 4.2">
</a>
<a href="https://github.com/stickytools/sticky-locking/" target="_blank">
    <img src="https://img.shields.io/cocoapods/v/StickyLocking.svg?style=flat" alt="Pod version">
</a>
<a href="https://travis-ci.org/stickytools/sticky-locking" target="_blank">
  <img src="https://travis-ci.org/stickytools/sticky-locking.svg?branch=master" alt="travis-ci.org" />
</a>
<a href="https://codecov.io/gh/stickytools/sticky-locking" target="_blank">
  <img src="https://codecov.io/gh/stickytools/sticky-locking/branch/master/graph/badge.svg" alt="Codecov" />
</a>

**StickyLocking** is a general purpose embedded lock manager which  allows for locking any resource hierarchy.  Installable Lock modes allow for customization of the locking system that can meet the needs of almost any locking scenario.

## Documentation

Sticky Locking provides the `Locker` class which is a high-level locking system designed to facilitate many different concurrency use cases including simple readers-writer locks which provide shared access for read operations and
exclusive access for write operations to more complex hierarchical locking schemes used to power database file,
database, page, and row level locking.

Sticky Locking also provides a low-level mutual exclusion lock through the `Mutex` class to protect critical sections of
your code.  In addition, wait conditions (`Condition`) are provided to allow for threads to wait for a mutex to
become available.

The mutual exclusion lock is provided through the `Mutex` class while wait conditions can be created with the
`Condition` class.  Internally, the higher level components are implemented using these two primitives, and other
modules in the Sticky Tools suite of libraries also use the mutex for protecting various critical sections of code.

### Hierarchical Locker

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

`ExtendedLockMode` an extended mode that includes intention and update modes which can be used for advanced database
type use cases.  This LockMode set was designed to be used by other models in the Sticky Tools suite of libraries.

You are free to define your own LockMode set depending on your use case, from simpler mode structures to more complex,
Sticky Locking will adapt to the mode given.

#### Defining Locker Behavior

The `Locker`s behavior is defined by the `LockMode`, `CompatibilityMatrix`, and `GroupModeMatrix`. These types and
structures define how the Locker will grant requests for lock modes.

A `LockMode` is an enum entry that defines a specific mode of the lock.  These modes are user defined

##### Lock Modes

Lock modes determine the symbols used to define the modes a lock can be in.

Here is an example of a simple lock mode definition:
```swift
    enum MyLockMode: LockMode {
        case S  /// Shared
        case X  /// Exclusive
    }
```
The mode on it's own only defines the symbols that can be used.  You must define a `CompatibilityMatrix` and `GroupModeMatrix` to describe how the various modes interact with each other.

> Note: Sticky Locking defines two built in `LockMode` enums along with corresponding compatibility and group mode matrix's.  A simple readers-writer type named `SharedExclusiveLockMode` and an extended mode named `ExtendedLockMode` which is suitable for advanced data storage applications.

##### Lock Mode Compatibility

The ability to share a lock mode with another request/thread is determined by the lock mode compatibility matrix
supplied for the lock mode.  For every new lock request, the matrix is checked and if the value at the index of the
current lock mode and the requested lock mode is `true` the lock will be granted concurrently, otherwise the request
will queue and wait.
```swift
    let compatibilityMatrix: CompatibilityMatrix<MyLockMode>
            = [
                /*               Shared, Exclusive  */
                /* Shared    */  [true,    false],
                /* Exclusive */  [false,   false],
              ]
```

##### Lock Group Mode

When multiple requests are compatible and granted concurrently the lock mode of the group must be calculated.  This
is called the group mode.  A new request is compatible with the members of the group if it is compatible with the
group mode.

Sticky Locking uses the `GroupModeMatrix` to determine the group mode when a new request joins the group.
```swift
    let groupModeMatrix: GroupModeMatrix<MyLockMode>
            = [
                /* Requested     Shared, Exclusive  */
                /* Shared    */  [S,     X],
                /* Exclusive */  [X,     X],
              ]
```

> See [Lock Wait State & Grant Behavior](Documentation/Lock&#32;Wait&#32;State&#32;&amp;&#32;Grant&#32;Behavior.md) for a more detailed description and examples of how the locker behaves during locking.

#### Built-in Lock Modes

Sticky Locking contains two pre-defined `LockMode` enums and associated matrix's for use with various use cases.

##### Shared-Exclusive Lock Mode

A Shared Exclusive lock (a.k.a. readers-writer or multi-reader) allows concurrent access for read-only
operations, while write operations gain exclusive access.

This allows multiple readers to gain shared access to a resource blocking all writers until no more
readers are reading.  Writers gain exclusive access to the resource blocking all other readers and writers
until the operation is complete.

The defined modes are:

 * S - Shared (Read)
 * X - Exclusive (Write)

The default `CompatibilityMatrix` is defined as:

| Requested |    S   |    X   |
|:---------:|:------:|:------:|
|  **S**    |&#x2714;|&#x2718;|
|  **X**    |&#x2718;|&#x2718;|

The default `GroupModeMatrix` is defined  as:

| Requested |   S    |    X   |
|:---------:|:------:|:------:|
|  **S**    |   S    |    X   |
|  **X**    |   X    |    X   |


##### Extended Lock Mode

The `ExtendedLockMode` is a predefined `LockMode` implementation that can be used for complex database type applications.  It defines
an extended set of lock modes including Update and Intention modes.

The defined modes are:

  * IS - Intention Shared
  * IX - Intention Exclusive
  * S - Shared
  * SIX - Shared Intention Exclusive
  * U - Update
  * X - Exclusive

The default `CompatibilityMatrix` is defined as:

| Requested |   IS   |   IX   |    S   |   SIX  |    U   |    X   |
|:---------:|:------:|:------:|:------:|:------:|:------:|:------:|
|  **IS**   |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2718;|
|  **IX**   |&#x2714;|&#x2714;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|
|  **S**    |&#x2714;|&#x2718;|&#x2714;|&#x2718;|&#x2714;|&#x2718;|
|  **SIX**  |&#x2714;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|
|  **U**    |&#x2714;|&#x2718;|&#x2714;|&#x2718;|&#x2718;|&#x2718;|
|  **X**    |&#x2718;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|

The default `GroupModeMatrix` is defined as:

| Requested |   IS   |   IX   |   S    |   SIX  |    U   |    X   |
|:---------:|:------:|:------:|:------:|:------:|:------:|:------:|
|  **IS**   |   IS   |   IX   |   S    |   SIX  |    U   |    X   |
|  **IX**   |   IX   |   IX   |   SIX  |   SIX  |    X   |    X   |
|  **S**    |   S    |   SIX  |   S    |   SIX  |    U   |    X   |
|  **SIX**  |   SIX  |   SIX  |   SIX  |   SIX  |    SIX |    X   |
|  **U**    |   U    |   X    |   U    |   SIX  |    U   |    X   |
|  **X**    |   X    |   X    |   X    |   X    |    X   |    X   |


#### Resources & Hashing

The `Locker` will lock and unlock any `Hashable` resource and it distinguishes the lock resources by the hash value,
therefore care must be taken to create a hashing algorithm that ensure uniqueness between individual objects of the
same type as well as the hash values between different types.

If two resources hash to the same hash value, and the two requested modes are incompatible, then the collision may
cause spurious waits.

Also keep in mind that the hashValue should never change for the resource.  If the hashValue changes over the life of the
resource, the locker will consider it a different resource each time the hashValue changes.  For instance, an Array<> hashValue
changes with each element that is added or removed to the array, therefore the Array<> instance itself could not be used
as a lock resource on its own.  You would have to use a surrogate Resource such as a fixed String or integer as the Resource
identifier.

### Mutexes & Conditions

Sticky Locking also provides a low-level mutual exclusion lock through the `Mutex` class to protect critical sections of your code.  In addition, wait conditions (`Condition`) are provided to allow for threads to wait for a mutex to become available.

The mutual exclusion lock is provided through the `Mutex` class while wait conditions can be created with the `Condition` class.  Internally, the higher level components are implemented using these two primitives, and other modules in the Sticky Tools suite of libraries also use the mutex for protecting various critical sections of code.

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

### Swift Package Manager

**StickyLocking** supports dependency management via Swift Package Manager on All Apple OS variants as well as Linux.

Please see [Swift Package Manager](https://swift.org/package-manager/#conceptual-overview) for further information.

### CocoaPods

StickyLocking is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
   pod "StickyLocking"
```

## Minimum Requirements

Build Environment

| Platform | Swift | Swift Build | Xcode |
|:--------:|:-----:|:----------:|:------:|
| Linux    | 4.2 | &#x2714; | &#x2718; |
| OSX      | 4.2 | &#x2714; | Xcode 10.0 |

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
