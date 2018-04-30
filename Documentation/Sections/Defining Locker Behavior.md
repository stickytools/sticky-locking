
# Defining Locker Behavior
---
The `Locker`s behaviour is defined by the `LockMode`, `CompatibilityMatrix`, and `GroupModeMatrix`. These types and 
structures define how the Locker will grant requests for lock modes. 

A `LockMode` is an enum entry that defines a specific mode of the lock.  These modes are user defined 

### Lock Modes

Lock modes determine the symbols used to define the modes a lock can be in.  

Here is an example of a simple lock mode definition:
```swift
    enum MyLockMode: LockMode {
        case S  /// Shared
        case X  /// Exclusive
    }
```
The mode on it's own only defines the symbols that can be used.  You must define a `CompatibilitMatrix` 
and `GroupModeMatrix` to describe how the various modes interact with each other.  
   
> Note: Sticky Locking defines two built in `LockMode` enums along with corresponding compatibility and 
> group mode matrix's.  A simple readers-writer type named `SharedExclusiveLockMode` and an extended mode named 
> `ExtendedLockMode` which is suitable for advanced data storage applications.
   
### Lock Mode Compatibility

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

### Lock Group Mode

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
# Lock Wait State & Grant Behavior
---
Locks can be in one of several states:

- **Granted** - The lock has been granted to the thread requesting the lock.  If this is a shared lock, many threads can be in the granted state simultaneously.
- **Waiting** - The lock is currently waiting to be granted.
- **Converting** - The lock is currently converting from one mode to another by a thread (e.g. Shared converting to Exclusive).  Many threads can be converting at the same time.  A thread that is converting must be in the granted state before conversion.

## Lock Grants

Lock requests are granted immediately under the following conditions:

1) There are no requests waiting for conversion to a different mode. 
2) There are no requests waiting for a new lock. 

Given the following empty lock queue:

    lock
      | 
      | queue ->

If thread 1 (`T1`)  requests an `S` lock, it is immediately granted because there are no conversion or waiters.

    lock (S)
      | 
      | queue -> (T1, S, granted) 

### Lock Wait State

Locks will be put into waiting state if any of the following conditions are true. 

1) The requested lock mode is not compatible with the current group mode.
2) There are existing waiting locks in the queue.
3) There are conversion requests in the queue.

#### Scenario 1 (not compatible with group mode)

Given the following lock queue of granted requests:

    lock (S)
      | 
      | granted -> (T1, S, granted) 

If thread 2 (`T2`) requests an X lock (exclusive), it must wait because it is not compatible with the existing granted group of S resulting in the following queue.

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, X, waiting) 

#### Scenario 2 (existing waiting requests)

Given the following lock queue:

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, X, waiting) 
    
If thread 3 (`T3`) requests an S lock (shared), even though it is compatible with the existing group mode (S), it must wait because there are other waiters in the queue.

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, X, waiting) --- (T3, S, waiting) 
    
#### Scenario 3 (existing conversion requests)

Given the following lock queue:

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T1, X, converting) 
    
If thread 3 (`T3`) requests an S lock (shared), even though it is compatible with the existing group mode (S), it must wait because there are conversion requests in the queue.
    
    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T1, X, converting) --- (T3, S, waiting) 
    
## Lock Conversion State

Threads can request conversion from one lock mode to another.  Either up-conversion, converting from a less strict to a more strict, or down-conversion, converting from a more strict to a less strict mode.  `StickyLocking` uses a FIFO lock allocation scheme with the exception of conversion which is always granted before new waiting requests.  Even though they take precedence over waiting new request, multiple conversion requests are granted in FIFO order.

### Scenario 1 (Immediate Conversion)

Immediate conversion of a request can be granted if the following conditions are true.

1) The requested conversion is compatible with the lock group mode.
2) There are no requests waiting for conversion to a different mode. 

#### Example 1 (no waiters)

Given the following lock queue of granted requests:

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T3, S, granted)
    
If thread 1 (`T1`)  requests conversion to `IS`, it is immediately granted, upgrading the group mode to `IS`.

    lock (IS)
      |
      | queue -> (T1, IS, granted) --- (T2, S, granted) --- (T3, S, granted) 
    
#### Example 2 (with waiters)

Given the following lock queue of granted and waiting requests:

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T3, S, granted) --- (T4, X, waiting)
    
If thread 1 (`T1`)  requests conversion to `IS`, it is immediately granted, upgrading the group mode to `IS`.

    lock (IS)
      |
      | queue -> (T1, IS, granted) --- (T2, S, granted) --- (T3, S, granted) --- (T4, X, waiting) 

### Lock Scenario 2 (Wait on conversion)

Conversion requests will wait if any of the following conditions are true.

1) The requested lock mode is not compatible with the group lock mode.
2) There are existing conversions waiting in the queue.

#### Example 1 (no queue)

Given the following lock queue of granted requests:

    lock (U)
      |
      | queue ->  (T1, U, granted) --- (T2, IS, granted) --- (T3, IS, granted) 

If thread 1 (`T1`) requests conversion to `X` the request will wait on the queue because the lock mode `X` is incompatible with the group lock mode `U`.

    lock (U)
      | 
      | queue -> (T1, U, granted) --- (T2, S, granted) --- (T3, IS, granted) --- (T1, X, converting)
    
Once request `T2` and `T3` unlock, `T1` will convert to `X` given the following queue.

    lock (X)
      |
      | queue -> (T1, X, granted)
    
#### Example 2 (with conversion queue)

Given the following lock queue of granted requests with a waiting on conversion queue:

    lock (U)
      | 
      | queue -> (T1, U, granted) --- (T2, IS, granted) --- (T3, IS, granted) --- (T2, IX, converting)
    
`T3` requests up-conversion to `IX` and since `T2` is already waiting, `T3` must also wait resulting in the following queue.

    lock (U)
      |
      | queue -> (T1, U, granted) --- (T2, IS, granted) --- (T3, IS, granted) --- (T2, IX, converting) --- (T3, IX, converting)
    
`T1` unlocks resulting in `T2` and `T3` being granted the up-conversion since `IS` and `IX` are compatible.

    lock (IX)
      |
      | queue -> (T2, IX, granted) --- (T3, IX, granted) 
    
### Lock scenario 3 (with waiting queue)

Conversion requests that can't be immediately granted will be placed in the queue before requests waiting for new locks.

Given the following lock queue of granted and waiting requests:

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T3, IX, waiting) --- (T4, IX, waiting)
    
If `T1` then requests an up-conversion from `S` to `X`, it will wait and be placed before requests waiting for new locks.

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T1, X, converting) --- (T3, IX, waiting) --- (T4, IX, waiting)

Once `T2` unlocks, `T1` will be granted it's conversion request before the request waiting for new locks are granted.

    lock (X)
      | 
      | queue -> (T1, X, granted) --- (T3, IX, waiting) --- (T4, IX, waiting)
    
### Conversion Deadlock

Certain situations can cause lock request to go into a deadlock state.  The most common cause it lock conversion as in the example below.

#### Example 1

Given the lock queue:

    lock (S)
      | 
      | queue -> (T1, S, granted) --- (T2, S, granted) 

`T1` and `T2` requests conversion to `X` causing a deadlock.

    lock (S)
      |
      | queue -> (T1, S, granted) --- (T2, S, granted) --- (T1, X, converting) --- (T2, X, converting)

