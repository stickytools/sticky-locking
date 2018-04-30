# Built-in Lock Modes

Sticky Locking contains two pre-defined `LockMode` enums for use with various use cases.

## Shared-Exclusive Lock Mode
---
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


## Extended Lock Mode
---
The `ExrendedLockMode` is a predefined `LockMode` implementation that can be used for complex database type applications.  It defines
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