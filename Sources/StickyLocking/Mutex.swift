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
#if os(Linux) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif

///
/// Mutually Exclusive Lock (Mutex) implementation.
///
internal class Mutex {

    ///
    /// The type of mutex to create.
    ///
    /// .normal: Lower overhead mutex that does not allow recursion.
    /// .recursive: Allows recursion but incures overhead due to having to keep track fo the calling thread.
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
        guard pthread_mutexattr_init(&attributes) == 0 else { preconditionFailure() }
        pthread_mutexattr_settype(&attributes, (type == .normal) ? Int32(PTHREAD_MUTEX_NORMAL) : Int32(PTHREAD_MUTEX_RECURSIVE))

        guard pthread_mutex_init(&mutex, &attributes) == 0 else { preconditionFailure() }
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
/// Condition implmentation.
///
internal class Condition {

    ///
    /// Initialize `self`
    ///
    init()  {
        guard pthread_cond_init(&condition, nil) == 0 else { preconditionFailure() }
    }
    deinit {
        pthread_cond_destroy(&condition)
    }

    ///
    /// Wait on condition represented by `self` re-aquiring mutex before return.
    ///
    @inline(__always)
    @discardableResult
    final func wait(_ mutex: Mutex) -> Bool {
        return pthread_cond_wait(&condition, &mutex.mutex) == 0
    }

    ///
    /// 
    ///
    @inline(__always)
    @discardableResult
    final func wait(_ mutex: Mutex, timeout: WaitTime) -> Bool {
        var timeout = timeout
        return pthread_cond_timedwait(&condition, &mutex.mutex, &timeout.timeSpec) == 0
    }
    
    ///
    ///
    ///
    @inline(__always)
    final func signal() {
        pthread_cond_signal(&condition)
    }

    private var condition = pthread_cond_t()
}
