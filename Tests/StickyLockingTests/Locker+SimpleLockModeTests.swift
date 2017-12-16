///
///  Locker+SimpleLockModeTests.swift
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
class LockerSimpleLockModeTests: XCTestCase {

    enum TestMode: Lock.Mode {
        case Shared, eXclusive

        public static let conflictMatrix = Lock.ConflictMatrix<TestMode>(arrayLiteral:
            [
                /* Requested     Shared, eXclusive  */
                /* Shared    */  [true,    false],
                /* eXclusive */  [false,   false],
            ]
        )

        public static let groupModeMatrix = Lock.GroupModeMatrix<TestMode>(arrayLiteral:
            [
                /* Requested     Shared,        eXclusive  */
                /* Shared    */  [Shared,       eXclusive],
                /* eXclusive */  [eXclusive,    eXclusive],
            ]
        )
    }

    let locker = Locker(conflictMatrix: TestMode.conflictMatrix, groupModeMatrix: TestMode.groupModeMatrix)

    func testInit() {
        XCTAssertNotNil(Locker(conflictMatrix: TestMode.conflictMatrix, groupModeMatrix: TestMode.groupModeMatrix))
    }

    // MARK: - Targeted Tests

    func testLockWhenNoOtherLocks() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .eXclusive), .granted)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockWhenExistingLockThatThreadOwns() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .eXclusive), .granted)
        XCTAssertEqual(locker.lock(input, mode: .eXclusive), .granted)

        /// Cleanup
        XCTAssertEqual(locker.unlock(input), true)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible() throws {
        let input = Lock.ResourceID(identifier: "database")
        let group = DispatchGroup()

        /// Aquire a lock on the main thread.
        XCTAssertEqual(self.locker.lock(input, mode: .Shared), .granted)

        /// Get a shared lock on a background thread
        DispatchQueue.global().async(group: group) {
            /// Now lock with a compatible lock in the backgroun.
            XCTAssertEqual(self.locker.lock(input, mode: .Shared), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .success)
        XCTAssertEqual(self.locker.unlock(input), true)            /// Clean up locks
    }

    func testLockWhenExistingIncompatibleLockForcesWait() throws {
        let input = Lock.ResourceID(identifier: "database")

        let group = DispatchGroup()

        /// Acquire a lock on the main thread.
        XCTAssertEqual(self.locker.lock(input, mode: .eXclusive), .granted)

        /// Lock an incompatible lock on a background thread.
        DispatchQueue.global().async(group: group) {
            XCTAssertEqual(self.locker.lock(input, mode: .Shared), .granted)
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
        let input = Lock.ResourceID(identifier: "database")

        let group = DispatchGroup()

        XCTAssertEqual(self.locker.lock(input, mode: .Shared), .granted)

        /// Lock an incompatible lock on a background thread.
        DispatchQueue.global().async(group: group) {
            /// Attempt to acquire a lock on the main thread and allow it to timeout.
            XCTAssertEqual(self.locker.lock(input, mode: .eXclusive, timeout: .now() + 0.1), .timeout)
        }
        group.wait()

        /// Cleanup
        XCTAssertEqual(self.locker.unlock(input), true)
    }

    func testLockWhenExistingIncompatibleLockAllowingTimeout() throws {
        let input = Lock.ResourceID(identifier: "database")

        let group = DispatchGroup()

        /// Acquire a lock on the main thread.
        XCTAssertEqual(self.locker.lock(input, mode: .eXclusive), .granted)

        for _ in 0..<10 {
            /// Lock an incompatible lock on a background thread.
            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(input, mode: .Shared, timeout: .now() + 0.1), .timeout)
            }
        }
        /// Now our lock should be acquired and has released the dispatch group.
        XCTAssertEqual(group.wait(timeout: .now() + 2.0), .success)

        /// Cleanup
        XCTAssertEqual(self.locker.unlock(input), true)
    }

    func testLockMultipleResourcesOnSameThread() throws {
        let input = (resourceID1: Lock.ResourceID(identifier: "database"), resourceID2: Lock.ResourceID(identifier: "page"))

        XCTAssertEqual(self.locker.lock(input.resourceID1, mode: .Shared), .granted)
        XCTAssertEqual(self.locker.lock(input.resourceID2, mode: .eXclusive), .granted)

        XCTAssertEqual(self.locker.unlock(input.resourceID2), true)
        XCTAssertEqual(self.locker.unlock(input.resourceID1), true)
    }

    // MARK: - Round trip tests

    func testLock() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .eXclusive), .granted)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockUnlockCycle() {
        let input = Lock.ResourceID(identifier: "database")

        let group = DispatchGroup()

        /// Repeated locks and unlocks
        for _ in 0..<5 {
            DispatchQueue.global().async(group: group) {

                XCTAssertEqual(self.locker.lock(input, mode: .eXclusive), .granted)
                XCTAssertEqual(self.locker.unlock(input), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleMultipleLocks() {
        let input = (resourceID1: Lock.ResourceID(identifier: "database"), resourceID2: Lock.ResourceID(identifier: "page"))

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for _ in 0..<5 {
            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(input.resourceID1, mode: .Shared), .granted)
                XCTAssertEqual(self.locker.lock(input.resourceID2, mode: .eXclusive), .granted)

                XCTAssertEqual(self.locker.unlock(input.resourceID2), true)
                XCTAssertEqual(self.locker.unlock(input.resourceID1), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleRecursiveLocks() {
        let input = (resourceID: Lock.ResourceID(identifier: "database"), lockCount: 5)

        for _ in 0..<input.lockCount {
            XCTAssertEqual(locker.lock(input.resourceID, mode: .eXclusive), .granted)
        }
        for _ in 0..<input.lockCount  {
            XCTAssertEqual(locker.unlock(input.resourceID), true)
        }
    }

    func testLockUnlockCycleMultipleLocksNonConflicting() {

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for i in 0..<50 {
            let database = Lock.ResourceID(identifier: "database #\(i)")
            let page     = Lock.ResourceID(identifier: "page #\(i)")

            DispatchQueue.global().async(group: group) {

                XCTAssertEqual(self.locker.lock(database, mode: .Shared), .granted)
                XCTAssertEqual(self.locker.lock(page, mode: .eXclusive), .granted)

                XCTAssertEqual(self.locker.unlock(page), true)
                XCTAssertEqual(self.locker.unlock(database), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleCompatibleLockMultipleLockers() {

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        let page = Lock.ResourceID(identifier: "page")

        for _ in 0..<5 {

            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(page, mode: .Shared), .granted)
                XCTAssertEqual(self.locker.unlock(page), true)
            }
        }
        group.wait()
    }

    // MARK: - Unlock tests

    func testUnlockWhenNothingLocked() {
        XCTAssertEqual(self.locker.unlock(Lock.ResourceID(identifier: "database")), false)
    }
}

