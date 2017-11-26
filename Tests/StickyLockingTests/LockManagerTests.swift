///
///  LockManagerTests.swift
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
///  Created by Tony Stone on 10/8/17.
///
import XCTest
import Dispatch

import StickyLocking

///
/// `LockManager` Tests
///
class LockManagerTests: XCTestCase {

    let lockManager = LockManager()

    func testInit() {
        XCTAssertNotNil(LockManager())
    }

    // MARK: - Targeted Tests

    func testLockWhenNoOtherLocks() throws {
        let input = ResourceID(identifier: "database")

        XCTAssertEqual(lockManager.lock(input, mode: .X), .granted)
    }

    func testLockWhenExistingLockThatThreadOwns() throws {
        let input = ResourceID(identifier: "database")

        XCTAssertEqual(lockManager.lock(input, mode: .X), .granted)
        XCTAssertEqual(lockManager.lock(input, mode: .X), .granted)
    }

    func testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible() throws {
        let input = ResourceID(identifier: "database")

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()

        /// Get a shared lock on a background thread
        queue.async(group: group) {
            XCTAssertEqual(self.lockManager.lock(input, mode: .S), .granted)
        }
        group.wait()    /// Wait to get it

        /// Now since try to aquire a compatible lock on the main thread.
        XCTAssertEqual(self.lockManager.lock(input, mode: .S), .granted)
    }

    func testLockWhenExistingIncompatibleLockForcesWait() throws {
        let input = ResourceID(identifier: "database")

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()

        /// Aquire a lock on the main thread.
        XCTAssertEqual(self.lockManager.lock(input, mode: .X), .granted)

        /// Lock an incompatible lock on a background thread.
        queue.async(group: group) {
            XCTAssertEqual(self.lockManager.lock(input, mode: .S), .granted)
            XCTAssertEqual(self.lockManager.unlock(input), true)
        }
        ///
        /// This call confirms that the dispatch group for the background lock
        /// is blocked, it should timeout.  If it does not the background lock
        /// completed immediately which is a failure.
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .timedOut)

        /// Now unlock the the main threads lock allowing it to be granted to the background waiter
        XCTAssertEqual(self.lockManager.unlock(input), true)

        /// Now our lock should be aquired and has released the dispatch group.
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .success)
    }

    func testLockMultipleResourcesOnSameThread() throws {
        let input = (resourceID1: ResourceID(identifier: "database"), resourceID2: ResourceID(identifier: "page"))

        XCTAssertEqual(self.lockManager.lock(input.resourceID1, mode: .IX), .granted)
        XCTAssertEqual(self.lockManager.lock(input.resourceID2, mode: .X), .granted)

        XCTAssertEqual(self.lockManager.unlock(input.resourceID2), true)
        XCTAssertEqual(self.lockManager.unlock(input.resourceID1), true)
    }

    // MARK: - Round trip tests

    func testLock() throws {
        let input = ResourceID(identifier: "database")

        XCTAssertEqual(lockManager.lock(input, mode: .X), .granted)
        XCTAssertEqual(lockManager.unlock(input), true)
    }

    func testLockUnlockCycle() {
        let input = ResourceID(identifier: "database")

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()

        /// Repeated locks and unlocks
        for _ in 0..<5 {
            queue.async(group: group) {

                XCTAssertEqual(self.lockManager.lock(input, mode: .X), .granted)
                XCTAssertEqual(self.lockManager.unlock(input), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleMultipleLocks() {
        let input = (resourceID1: ResourceID(identifier: "database"), resourceID2: ResourceID(identifier: "page"))

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for _ in 0..<5 {
            queue.async(group: group) {
                XCTAssertEqual(self.lockManager.lock(input.resourceID1, mode: .IX), .granted)
                XCTAssertEqual(self.lockManager.lock(input.resourceID2, mode: .X), .granted)

                XCTAssertEqual(self.lockManager.unlock(input.resourceID2), true)
                XCTAssertEqual(self.lockManager.unlock(input.resourceID1), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleRecursiveLocks() {
        let input = (resourceID: ResourceID(identifier: "database"), lockCount: 5)

        for _ in 0..<input.lockCount {
            XCTAssertEqual(lockManager.lock(input.resourceID, mode: .X), .granted)
        }
        for _ in 0..<input.lockCount  {
            XCTAssertEqual(lockManager.unlock(input.resourceID), true)
        }
    }

    func testLockUnlockCycleMultipleLocksNonConflicting() {

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for i in 0..<50 {
            let database = ResourceID(identifier: "database #\(i)")
            let page     = ResourceID(identifier: "page #\(i)")

            queue.async(group: group) {

                XCTAssertEqual(self.lockManager.lock(database, mode: .IX), .granted)
                XCTAssertEqual(self.lockManager.lock(page, mode: .X), .granted)

                XCTAssertEqual(self.lockManager.unlock(page), true)
                XCTAssertEqual(self.lockManager.unlock(database), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleCompatibleLockMulitpleLockers() {

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        let page = ResourceID(identifier: "page")

        for _ in 0..<5 {

            queue.async(group: group) {
                XCTAssertEqual(self.lockManager.lock(page, mode: .S), .granted)
                XCTAssertEqual(self.lockManager.unlock(page), true)
            }
        }
        group.wait()
    }
}
