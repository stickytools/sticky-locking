///
///  Lock.swift
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
///  Created by Tony Stone on 11/20/17.
///
import Foundation

///
/// Lock value class which represents a granted lock.
///
internal class Lock {

    init(mode: LockMode) {
        self.mode    = mode
        self.queue   = RequestQueue()
        self.mutex   = Mutex()
    }

    var mode:  LockMode       /// THe mode this lock was originally locked in.
    var queue: RequestQueue   /// Queue (FIFO) of lock requests for this lock (owners and waiters).
    let mutex: Mutex          /// Mutex for locking while maintaining owners and waiters as well as waiting on the lock with a condition.
}
