///
///  Lock+Requester.swift
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
///  Created by Tony Stone on 11/19/17.
///
import Foundation

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD) || os(PS4) || os(Android)  /* Swift 5 support: || os(Cygwin) || os(Haiku) */
    import Glibc
#endif

///
/// Lock auxiliary structures.
///
internal extension Lock {

    ///
    /// Class which identifies the requester that is locking or unlocking the lock.
    ///
    class Requester: Equatable {
        init() {
            self.thread = pthread_self()
        }

        @inline(__always)
        static func == (lhs: Requester, rhs: Requester) -> Bool {
            return lhs.thread == rhs.thread
        }
        private let thread: pthread_t
    }
}

///
/// `CustomStringConvertible` and `CustomDebugStringConvertible` conformance.
///
extension Lock.Requester: CustomStringConvertible, CustomDebugStringConvertible {

    var description: String {
        return "\(self.thread)"
    }
    var debugDescription: String {
        return "Locker(\(self.description))"
    }
}
