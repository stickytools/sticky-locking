///
///  Locker+RequestQueueTests.swift
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
///  Created by Tony Stone on 12/2/17.
///
import XCTest
import Dispatch

@testable import StickyLocking

class Locker_RequestQueueTests: XCTestCase {

    enum TestMode: Lock.Mode {
        case S, X
    }

    let queue = Locker<TestMode>.RequestQueue()

    func testCount() {

        for _ in 0..<5 {
            queue.add(Locker<TestMode>.Request(.S))
        }
        XCTAssertEqual(queue.count, 5)
    }

    func testCountAfterRemoval() {

        for _ in 0..<5 {
            queue.add(Locker<TestMode>.Request(.S))
        }

        for request in queue.reversed() {
            queue.remove(request)
        }
        XCTAssertEqual(queue.count, 0)
    }

    func testContainsTrue() {

        let request = Locker<TestMode>.Request(.S)
        request.status = .granted

        queue.add(request)

        XCTAssertTrue(queue.contains(status: Locker<TestMode>.Request.Status.granted))
    }

    func testContainsFalse() {

        let request = Locker<TestMode>.Request(.S)
        request.status = .granted

        queue.add(request)

        XCTAssertFalse(queue.contains(status: Locker<TestMode>.Request.Status.requested))
    }

    func testFindTrue() {

        let request = Locker<TestMode>.Request(.S)
        request.status = .granted

        queue.add(request)

        XCTAssertEqual(queue.find(for: Locker<TestMode>.Requester()), request)
    }

    func testFindFalse() {

        let group = DispatchGroup()

        DispatchQueue.global().async(group: group) {
            let request = Locker<TestMode>.Request(.S)
            request.status = .granted

            self.queue.add(request)
        }
        group.wait()

        XCTAssertEqual(queue.find(for: Locker<TestMode>.Requester()), nil)
    }

    func testAdd() {

        let request = Locker<TestMode>.Request(.S)
        request.status = .granted

        queue.add(request)

        XCTAssertTrue(queue.contains(request))
    }

    func testRemove() {

        let request = Locker<TestMode>.Request(.S)
        request.status = .granted

        queue.add(request)
        queue.remove(request)

        XCTAssertFalse(queue.contains(request))
    }

    func testRemoveNonExisting() {

        let request = Locker<TestMode>.Request(.S)
        request.status = .granted

        queue.remove(request)

        XCTAssertFalse(queue.contains(request))
    }

}
