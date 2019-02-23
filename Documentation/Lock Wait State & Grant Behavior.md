# Lock Wait State & Grant Behavior

Locks in the Locker can be in one of several states depending contention for the locks.

The three states are:

- **Granted** - The lock has been granted to the thread requesting the lock.  If this is a shared lock, many threads can be in the granted state simultaneously.
- **Waiting** - The lock is currently waiting to be granted.
- **Converting** - The lock is currently converting from one mode to another by a thread (e.g. Shared converting to Exclusive).  Many threads can be converting at the same time.  A thread that is converting must be in the granted state before conversion.

Lock grants are given based on the `LockMode`, `CompatibilityMatrix`, and `GroupModeMatrix` in use at
the time.  Below are a series of examples based on the built in `ExtendedLockMode`.  The `ExtendedLockMode`
has the following definition.

The defined modes are:

  * IS - Intention Shared
  * IX - Intention Exclusive
  * S - Shared
  * SIX - Shared Intention Exclusive
  * U - Update
  * X - Exclusive

The `CompatibilityMatrix` is defined as:

| Requested |   IS   |   IX   |    S   |   SIX  |    U   |    X   |
|:---------:|:------:|:------:|:------:|:------:|:------:|:------:|
|  **IS**   |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2718;|
|  **IX**   |&#x2714;|&#x2714;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|
|  **S**    |&#x2714;|&#x2718;|&#x2714;|&#x2718;|&#x2714;|&#x2718;|
|  **SIX**  |&#x2714;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|
|  **U**    |&#x2714;|&#x2718;|&#x2714;|&#x2718;|&#x2718;|&#x2718;|
|  **X**    |&#x2718;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|&#x2718;|

The `GroupModeMatrix` is defined as:

| Requested |   IS   |   IX   |   S    |   SIX  |    U   |    X   |
|:---------:|:------:|:------:|:------:|:------:|:------:|:------:|
|  **IS**   |   IS   |   IX   |   S    |   SIX  |    U   |    X   |
|  **IX**   |   IX   |   IX   |   SIX  |   SIX  |    X   |    X   |
|  **S**    |   S    |   SIX  |   S    |   SIX  |    U   |    X   |
|  **SIX**  |   SIX  |   SIX  |   SIX  |   SIX  |    SIX |    X   |
|  **U**    |   U    |   X    |   U    |   SIX  |    U   |    X   |
|  **X**    |   X    |   X    |   X    |   X    |    X   |    X   |


## Lock Grants

Using the above definitions, lock requests are granted immediately under the following conditions:

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

