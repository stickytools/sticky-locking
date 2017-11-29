///
///  Lock+RequesterTests.swift
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
///  Created by Tony Stone on 11/24/17.
///
import XCTest
import Dispatch

@testable import StickyLocking

class LockRequesterTests: XCTestCase {

    func testInit() {
        let thread: pthread_t = pthread_self()

        XCTAssertEqual(Lock.Requester().description, "\(thread)")
    }

    func testEqualTrue() {
        XCTAssertEqual(Lock.Requester(), Lock.Requester())
    }

    func testEqualFalse() {
        let group = DispatchGroup()

        /// Force new thread to get another requester instance.
        var other = Lock.Requester()
        DispatchQueue.global().async(group: group) {
            other = Lock.Requester()
        }
        group.wait()

        XCTAssertNotEqual(Lock.Requester(), other)
    }

    func testDescription() {
        let thread: pthread_t = pthread_self()

        XCTAssertEqual(Lock.Requester().description, "\(thread)")
    }

    func testDebugDescription() {
        let thread: pthread_t = pthread_self()

        XCTAssertEqual(Lock.Requester().debugDescription, "Locker(\(thread))")
    }
}
