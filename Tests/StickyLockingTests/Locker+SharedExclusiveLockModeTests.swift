///
///  Locker+SharedExclusiveLockModeTests.swift
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

import StickyLocking

///
/// `Locker` Tests
///
class LockerSharedExclusiveLockModeTests: XCTestCase {
    
    let locker = Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)

    func testInit() {
        XCTAssertNotNil(Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix))
    }

    // MARK: - Targeted Tests

    func testLockWhenNoOtherLocks() throws {
        let input = "database1"

        XCTAssertEqual(locker.lock(input, mode: .X), .granted)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockWhenExistingLockThatThreadOwns() throws {
        let input = "database1"

        XCTAssertEqual(locker.lock(input, mode: .X), .granted)
        XCTAssertEqual(locker.lock(input, mode: .X), .granted)

        /// Cleanup
        XCTAssertEqual(locker.unlock(input), true)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible() throws {
        let input = "database1"
        let group = DispatchGroup()

        /// Aquire a lock on the main thread.
        XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

        /// Get a shared lock on a background thread
        DispatchQueue.global().async(group: group) {
            /// Now lock with a compatible lock in the backgroun.
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .success)
        XCTAssertEqual(self.locker.unlock(input), true)            /// Clean up locks
    }

    func testLockWhenExistingIncompatibleLockForcesWait() throws {
        let input = "database1"

        let group = DispatchGroup()

        /// Acquire a lock on the main thread.
        XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)

        /// Lock an incompatible lock on a background thread.
        DispatchQueue.global().async(group: group) {
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        ///
        /// This call confirms that the dispatch group for the background lock
        /// is blocked, it should timeout.  If it does not the background lock
        /// completed immediately which is a failure.
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .timedOut)

        /// Now unlock the the main threads lock allowing it to be granted to the background waiter
        XCTAssertEqual(self.locker.unlock(input), true)

        /// Now our lock should be acquired and has released the dispatch group.
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .success)
    }

    func testLockWhenExistingIncompatibleLockForcesWaitWithTimeout() throws {
        let input = "database1"

        let group = DispatchGroup()

        XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

        /// Lock an incompatible lock on a background thread.
        DispatchQueue.global().async(group: group) {
            /// Attempt to acquire a lock on the main thread and allow it to timeout.
            XCTAssertEqual(self.locker.lock(input, mode: .X, timeout: .now() + 0.1), .timeout)
        }
        group.wait()

        /// Cleanup
        XCTAssertEqual(self.locker.unlock(input), true)
    }

    func testLockWhenExistingIncompatibleLockAllowingTimeout() throws {
        let input = "database1"

        let group = DispatchGroup()

        /// Acquire a lock on the main thread.
        XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)

        for _ in 0..<10 {
            /// Lock an incompatible lock on a background thread.
            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(input, mode: .S, timeout: .now() + 0.1), .timeout)
            }
        }
        /// Now our lock should be acquired and has released the dispatch group.
        XCTAssertEqual(group.wait(timeout: .now() + 2.0), .success)

        /// Cleanup
        XCTAssertEqual(self.locker.unlock(input), true)
    }

    func testLockMultipleResourcesOnSameThread() throws {
        let input = (resource1: "database1", resource2: "page1")

        XCTAssertEqual(self.locker.lock(input.resource1, mode: .S), .granted)
        XCTAssertEqual(self.locker.lock(input.resource2, mode: .X), .granted)

        XCTAssertEqual(self.locker.unlock(input.resource2), true)
        XCTAssertEqual(self.locker.unlock(input.resource1), true)
    }

    // MARK: - Round trip tests

    func testLock() throws {
        let input = "database1"

        XCTAssertEqual(locker.lock(input, mode: .X), .granted)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockUnlockCycle() {
        let input = "database1"

        let group = DispatchGroup()

        /// Repeated locks and unlocks
        for _ in 0..<5 {
            DispatchQueue.global().async(group: group) {

                XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)
                XCTAssertEqual(self.locker.unlock(input), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleMultipleLocks() {
        let input = (resource1: "database1", resource2: "page1")

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for _ in 0..<5 {
            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(input.resource1, mode: .S), .granted)
                XCTAssertEqual(self.locker.lock(input.resource2, mode: .X), .granted)

                XCTAssertEqual(self.locker.unlock(input.resource2), true)
                XCTAssertEqual(self.locker.unlock(input.resource1), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleRecursiveLocks() {
        let input = (resource: "database1", lockCount: 5)

        for _ in 0..<input.lockCount {
            XCTAssertEqual(locker.lock(input.resource, mode: .X), .granted)
        }
        for _ in 0..<input.lockCount  {
            XCTAssertEqual(locker.unlock(input.resource), true)
        }
    }

    func testLockUnlockCycleMultipleLocksNonConflicting() {

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for i in 0..<50 {
            let database = "database\(i)"
            let page     = "database\(i):page\(i)"

            DispatchQueue.global().async(group: group) {

                XCTAssertEqual(self.locker.lock(database, mode: .S), .granted)
                XCTAssertEqual(self.locker.lock(page, mode: .X), .granted)

                XCTAssertEqual(self.locker.unlock(page), true)
                XCTAssertEqual(self.locker.unlock(database), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleCompatibleLockMultipleLockers() {

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        let page = "page1"

        for _ in 0..<5 {

            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(page, mode: .S), .granted)
                XCTAssertEqual(self.locker.unlock(page), true)
            }
        }
        group.wait()
    }

    // MARK: - Unlock tests

    func testUnlockWhenNothingLocked() {
        XCTAssertEqual(self.locker.unlock("database1"), false)
    }

    func testUnlockWhenLockNotOwnedByRequester() throws {
        let input = "database1"
        let expected = false

        let group = DispatchGroup()
        group.enter()

        DispatchQueue.global().async {
            _ = self.locker.lock(input, mode: .X)
            group.leave()
        }
        group.wait()

        XCTAssertEqual(locker.unlock(input), expected)
    }
}

