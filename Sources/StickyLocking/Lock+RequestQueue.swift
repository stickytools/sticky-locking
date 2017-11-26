///
///  RequestQueue.swift
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
///  Created by Tony Stone on 11/22/17.
///
import Swift

extension Lock {

    ///
    /// FIFO queue of Requests stored as a linked list.
    ///
    internal class RequestQueue: Sequence {

        typealias Iterator = Array<Request>.Iterator

        ///
        /// The number of entries in the queue.
        ///
        var count: Int {
            @inline(__always)
            get { return storage.count }
        }

        ///
        /// Are there any entries with the status in the queue
        ///
        @inline(__always)
        func contains(status: Lock.Request.Status) -> Bool {
            return storage.contains(where: { $0.status == status })
        }

        ///
        /// Returns an existing entry that contains a matching `Locker`.
        ///
        @inline(__always)
        @discardableResult
        func find(for locker: Locker) -> Request? {
            guard let index = storage.index(where: { $0.locker == locker })
                else { return nil }

            return storage[index]
        }

        ///
        /// Remove `request` from queue.
        ///
        @inline(__always)
        func remove(request: Request) {
            guard let index = storage.index(of: request)
                else { return }
            storage.remove(at: index)
        }

        ///
        /// Add a value onto the end of the queue.
        ///
        @inline(__always)
        func add(_ request: Request) {
            storage.append(request)
        }


        // MARK: Sequence Conformance
        func makeIterator() -> Lock.RequestQueue.Iterator {
            return storage.makeIterator()
        }

        private var storage: [Request] = []
    }
}
