///
///  Lock+Request.swift
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
///  Created by Tony Stone on 11/23/17.
///
import Swift

///
/// Auxiliary Structures
///
extension Lock {

    ///
    /// Lock Request to record requests in the queue.
    ///
    internal class Request: Equatable {

        ///
        /// Request status types
        ///
        enum Status {
            case requested  /// Initial state, the lock has been requested by a thread.
            case waiting    /// The request is currently in a wait state waiting for the lock to become free.
            case granted    /// The request has been granted the requested lock in the requested mode.
            case denied     /// The request has been denied.
            case timeout    /// The request timed out waiting for the lock to become free.
            case deadlock   /// A deadlock was detected and the lock was denied.
        }

        ///
        /// Initialize `self` with the initial `mode` and an optional `requester`.
        ///
        /// - Note: `requester` will default to the current threads requester if not passed.
        ///
        init(_ mode: LockMode, requester: Requester = Requester()) {
            self.mode      = mode
            self.count     = 1         /// Initial request is the first
            self.requester = requester
            self.status    = .requested
            self.condition = Condition()
        }

        ///
        /// Make the `Request` wait until it's signaled to wake up.
        ///
        /// - Parameter mutex: The mutex to re-acquire before being signaled.
        ///
        /// - Note: You must bracket this call to a call to mutex.lock/unlock.  Upon return from this method, the mutex passed will be required.  You must unlock it again after return.
        ///
        @inline(__always)
        @discardableResult
        func wait(on mutex: Mutex) -> Condition.WaitResult {
            return self.condition.wait(mutex)
        }

        @inline(__always)
        @discardableResult
        func wait(on mutex: Mutex, timeout: WaitTime) -> Condition.WaitResult {
            return self.condition.wait(mutex, timeout: timeout)
        }

        ///
        /// Wakeup the request after being put into a wait condition with `wait(mutex:)`.
        ///
        @inline(__always)
        func signal() {
            self.condition.signal()
        }

        ///
        /// Are 2 `Request`s equal?
        ///
        @inline(__always)
        static func == (lhs: Request, rhs: Request) -> Bool {
            return lhs.mode == rhs.mode && lhs.requester == rhs.requester
        }

        let mode: LockMode        /// The requested lock mode.
        var count: Int            /// The number of times this Requester requested this lock.

        let requester: Requester  /// The requester of this lock request.
        var status: Status        /// the current request status (.waiting, .granted, etc).

        private let condition: Condition    /// Condition variable to allow waiting until condition is signaled.
    }
}
