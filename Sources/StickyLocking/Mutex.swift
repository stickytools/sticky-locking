///
///  Mutex.swift
///
///  Copyright 2017 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 11/10/17.
///
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD) || os(PS4) || os(Android)  /* Swift 5 support: || os(Cygwin) || os(Haiku) */
    import Glibc
#endif

///
/// Mutually Exclusive Lock (Mutex) implementation.
///
internal class Mutex {

    ///
    /// The type of mutex to create.
    ///
    /// .normal: Lower overhead mutex that does not allow recursion.
    /// .recursive: Allows recursion but incurs overhead due to having to keep track fo the calling thread.
    ///
    enum MutexType { case normal, recursive }

    ///
    /// Initialize `self`
    ///
    /// - Parameter type: `MutexType` to to create.  Default is normal
    ///
    /// - Seealso: `MutexType`
    ///
    /// - Note: Care must be taken to ensure matching (lock|tryLock)/unlock pairs, otherwise undefined behaviour can occur.
    ///
    init(_ type: MutexType = .normal)  {

        var attributes = pthread_mutexattr_t()
        guard pthread_mutexattr_init(&attributes) == 0 else { fatalError("pthread_mutexattr_init") }
        pthread_mutexattr_settype(&attributes, (type == .normal) ? Int32(PTHREAD_MUTEX_NORMAL) : Int32(PTHREAD_MUTEX_RECURSIVE))

        guard pthread_mutex_init(&mutex, &attributes) == 0 else { fatalError("pthread_mutex_init") }
        pthread_mutexattr_destroy(&attributes)
    }
    deinit {
        pthread_mutex_destroy(&mutex)
    }

    ///
    /// Lock the mutex waiting indefinitely for the lock.
    ///
    @inline(__always)
    final func lock() {
        pthread_mutex_lock(&mutex)
    }

    ///
    /// Attempt to obtain the lock and return immediately returning `true` if the lock was acquired and `false` otherwise.
    ///
    /// - Note: If mutex is of type `MutexType.recursive` and the mutex is currently owned by the calling thread, the mutex lock count will be incremented.
    ///
    /// - Important: When ever tryLock returns `true`, you must have a matching `unlock` call for the try lock.
    ///
    @inline(__always)
    final func tryLock() -> Bool {
        return pthread_mutex_trylock(&mutex) == 0
    }

    ///
    /// Unlock the mutex.
    ///
    @inline(__always)
    final func unlock() {
        pthread_mutex_unlock(&mutex)
    }

    fileprivate var mutex = pthread_mutex_t()
}

///
/// Condition implementation.
///
internal class Condition {

    ///
    /// Enumeration of result codes from a wait.
    ///
    enum WaitResult {
        case success, timeout, error
    }

    ///
    /// Initialize `self`
    ///
    init()  {
        guard pthread_cond_init(&condition, nil) == 0 else { fatalError("pthread_cond_init") }
    }
    deinit {
        pthread_cond_destroy(&condition)
    }

    ///
    /// Wait on condition represented by `self` re-acquiring the mutex before returning.
    ///
    @inline(__always)
    @discardableResult
    final func wait(_ mutex: Mutex) -> WaitResult {
        switch pthread_cond_wait(&condition, &mutex.mutex) {
        case 0:  return .success
        default: return .error
        }
    }

    ///
    /// Wait on condition represented by `self` re-acquiring the mutex before returning. If timeout is exceeded, return a timeout result.
    ///
    @inline(__always)
    @discardableResult
    final func wait(_ mutex: Mutex, timeout: WaitTime) -> WaitResult {
        var timeout = timeout
        switch pthread_cond_timedwait(&condition, &mutex.mutex, &timeout.timeSpec) {
        case 0:         return .success
        case ETIMEDOUT: return .timeout
        default:        return .error
        }
    }
    
    ///
    /// Signal the waiter, allowing it to re-aquire the mutex and continue.
    ///
    @inline(__always)
    final func signal() {
        pthread_cond_signal(&condition)
    }

    private var condition = pthread_cond_t()
}
