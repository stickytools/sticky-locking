///
///  Locker+DefaultLockModeTests.swift
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
/// `Locker` Tests
///
class LockerDefaultLockModeTests: XCTestCase {

    let locker = Locker(conflictMatrix: LockMode.conflictMatrix, groupModeMatrix: LockMode.groupModeMatrix)

    func testInit() {
        XCTAssertNotNil(Locker(conflictMatrix: LockMode.conflictMatrix, groupModeMatrix: LockMode.groupModeMatrix))
    }

    // MARK: - Lock Grant
    // MARK: Lock Scenario 1 (immediate grant)

    ///
    /// Given the following empty lock queue:
    ///
    /// ```
    /// Lock
    ///   |
    ///   | queue ->
    /// ```
    ///
    /// If thread 1 (`T1`)  requests an `S` lock, it is immediately granted because there are no conversion or waiters.
    ///
    ///
    ///```
    /// Lock (S)
    ///   |
    ///   | queue -> (T1, S, granted)
    /// ```
    ///
    func testLockGrantWhenNoOtherLocks() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .S), .granted)
        XCTAssertEqual(locker.unlock(input), true)
    }

    // MARK: Lock Wait
    // MARK: Scenario 1 (not compatible with group mode)

    ///
    /// Given the following lock queue of granted requests:
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | queue -> (T1, S, granted)
    /// ```
    ///
    /// If thread 2 (`T2`) requests an X lock (exclusive), it must wait because it is not compatible with the existing granted group of S resulting in the following queue.
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | queue -> (T1, S, granted) --- (T2, X, waiting)
    /// ```
    func testLockWaitScenario1NotCompatibleWithGroupMode() throws {
        let input = Lock.ResourceID(identifier: "database")

        let backgroup = DispatchGroup()
        let locked    = DispatchGroup()
        /// Lock the input in S mode so we can convert it later
        XCTAssertEqual(locker.lock(input, mode: .S), .granted)

        locked.enter()
        DispatchQueue.global().async(group: backgroup) {
            locked.leave()   /// Signal that we are locked.
            XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        locked.wait()   /// Wait for all to be locked
        usleep(100)
        XCTAssertEqual(locker.unlock(input), true)

        backgroup.wait() /// Wait for the background group to finished cleaning up.
    }

    // Scenario 2 (existing waiting requests)

    ///
    /// Given the following lock queue:
    ///
    /// ```
    /// Lock (S)
    ///    |
    ///    | queue -> (T1, S, granted) --- (T2, X, waiting)
    /// ```
    ///
    /// If thread 3 (`T3`) requests an S lock (shared), even though it is compatible with the existing group mode (S), it must wait because there are other waiters in the queue.
    ///
    /// ```
    /// Lock (S)
    ///    |
    ///    | queue -> (T1, S, granted) --- (T2, X, waiting) --- (T3, S, waiting)
    /// ```
    ///
    func testLockWaitScenario2ExistingWaitingRequests() throws {
        let input = Lock.ResourceID(identifier: "database")

        let backgroup = DispatchGroup()
        let locked    = DispatchGroup()
        /// Lock the input in S mode so we can convert it later
        XCTAssertEqual(locker.lock(input, mode: .S), .granted)

        locked.enter()
        DispatchQueue.global().async(group: backgroup) {
            locked.leave()   /// Signal that we are locked.
            XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        locked.wait()   /// Wait for all to be locked

        usleep(100)

        locked.enter()
        DispatchQueue.global().async(group: backgroup) {
            locked.leave()   /// Signal that we are locked.
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        locked.wait()   /// Wait for all to be locked

        usleep(100)
        XCTAssertEqual(locker.unlock(input), true)

        backgroup.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: Scenario 3 (existing conversion requests)

    ///
    /// Given the following lock queue:
    ///
    /// ```
    /// Lock (S)
    ///    |
    ///    | queue -> (T1, S, granted) --- (T2, S, granted) --- (T2, X, converting)
    /// ```
    ///
    /// If thread 3 (`T3`) requests an S lock (shared), even though it is compatible with the existing group mode (S), it must wait because there are conversion requests in the queue.
    ///
    /// ```
    /// Lock (S)
    ///    |
    ///    | queue -> (T1, S, granted) --- (T2, S, granted) --- (T2, X, converting) --- (T3, S, waiting)
    /// ```
    ///
    func testLockWaitScenario3ExistingConversionRequests() throws {
        let input = Lock.ResourceID(identifier: "database")

        let requester = DispatchGroup()
        let convert   = DispatchGroup()
        let locked    = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()
        convert.enter()

        DispatchQueue.global().async(group: requester) {

            /// Lock the input in S mode so we can convert it later
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

            locked.enter()
            DispatchQueue.global().async(group: requester) {
                XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

                locked.leave()   /// Signal that we are locked.

                /// Now upgrade the lock
                XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)

                cleanup.wait()   /// Wait to cleanup

                XCTAssertEqual(self.locker.unlock(input), true)
                XCTAssertEqual(self.locker.unlock(input), true)
            }
            locked.wait()

            locked.enter()
            DispatchQueue.global().async(group: requester) {

                locked.leave()   /// Signal that we are locked.
                XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)
                XCTAssertEqual(self.locker.unlock(input), true)
            }
            locked.wait()
            convert.leave()

            usleep(200) /// Sleep to give the X lock a chance to lock.

            XCTAssertEqual(self.locker.unlock(input), true)
        }

        cleanup.leave() /// Allow thrads to cleanup.
        requester.wait() /// Wait for the background group to finished cleaning up.
    }
    
    // MARK: - Lock Conversion
    // MARK: Lock Scenario 1 (Immediate Conversion)- Example 1 (no waiters)

    ///
    /// Given the following lock queue of granted requests:
    ///
    /// ```
    ///  Lock (S)
    ///    |
    ///    | -> (T1, S, granted) --- (T2, S, granted) --- (T3, S, granted)
    /// ```
    ///
    /// If thread 1 (`T1`)  requests conversion to `IS`, it is immediately granted, upgrading the group mode to `IS`.
    ///
    /// ```
    ///  Lock (IS)
    ///    |
    ///    | -> (T1, IS, granted) --- (T2, S, granted) --- (T3, S, granted)
    /// ```
    ///
    func testLockConversionScenario1Example1ImmediateConversion() {
        let input = Lock.ResourceID(identifier: "database")

        let backgroup = DispatchGroup()
        let locked    = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()

        /// Lock the input in S mode so we can convert it later
        XCTAssertEqual(locker.lock(input, mode: .S), .granted)

        for _ in 0..<2 {
            locked.enter()

            DispatchQueue.global().async(group: backgroup) {
                XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

                locked.leave()   /// Signal that we are locked.
                cleanup.wait()   /// Wait to cleanup

                XCTAssertEqual(self.locker.unlock(input), true)
            }
        }
        locked.wait()   /// Wait for all to be locked

        XCTAssertEqual(locker.lock(input, mode: .IS), .granted)
        /// Note: we locked the same resource twice so we need to unlock twice.
        XCTAssertEqual(locker.unlock(input), true)
        XCTAssertEqual(locker.unlock(input), true)

        cleanup.leave() /// Allow threads to cleanup.
        backgroup.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: Example 2 (with waiters)

    ///
    /// Given the following lock queue of granted and waiting requests:
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | -> (T1, S, granted) --- (T2, S, granted) --- (T3, S, granted) --- (T4, X, waiting)
    /// ```
    ///
    /// If thread 1 (`T1`)  requests conversion to `IS`, it is immediately granted, upgrading the group mode to `IS`.
    ///
    /// ```
    /// Lock (IS)
    ///   |
    ///   | -> (T1, IS, granted) --- (T2, S, granted) --- (T3, S, granted) --- (T4, X, waiting)
    /// ```
    ///
    func testLockConversionScenario1Example2ImmediateConversionWithWaitQueue() {
        let input = Lock.ResourceID(identifier: "database")

        let requester = DispatchGroup()
        let convert   = DispatchGroup()
        let locked    = DispatchGroup()
        let blocked   = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()
        convert.enter()

        DispatchQueue.global().async(group: requester) {

            /// Lock the input in S mode so we can convert it later
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

            for _ in 0..<2 {

                locked.enter()
                DispatchQueue.global().async(group: requester) {
                    XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

                    locked.leave()   /// Signal that we are locked.
                    cleanup.wait()   /// Wait to cleanup

                    XCTAssertEqual(self.locker.unlock(input), true)
                }
            }
            locked.wait()

            blocked.enter()
            DispatchQueue.global().async(group: requester) {
                blocked.leave()   /// Signal that we are locked.
                XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)

                cleanup.wait()   /// Wait to cleanup

                XCTAssertEqual(self.locker.unlock(input), true)
            }
            blocked.wait()

            usleep(100) /// Sleep to give the X lock a chance to lock.

            convert.leave()
            XCTAssertEqual(self.locker.lock(input, mode: .IS), .granted)

            /// Note: we locked the same resource twice so we need to unlock twice.
            XCTAssertEqual(self.locker.unlock(input), true)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        convert.wait()

        usleep(100)
        cleanup.leave() /// Allow thrads to cleanup.
        requester.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: - Lock Scenario 2 (Wait on conversion)
    // MARK: Example 1 (no queue)

    ///
    /// Given the following lock queue of granted requests:
    ///
    /// ```
    /// Lock (U)
    ///   |
    ///   | ->  (T1, U, granted) --- (T2, IS, granted) --- (T3, IS, granted)
    /// ```
    ///
    /// If thread 1 (`T1`) requests conversion to `X` the request will wait on the queue because the lock mode `X` is incompatible with the group lock mode `U`.
    ///
    /// ```
    /// Lock (U)
    ///   |
    ///   | -> (T1, U, granted) --- (T2, S, granted) --- (T3, IS, granted) --- (T1, X, converting)
    /// ```
    ///
    /// Once request `T2` and `T3` unlock, `T1` will convert to `X` given the following queue.
    ///
    /// ```
    /// Lock (X)
    ///   |
    ///   | -> (T1, X, granted)
    /// ```
    ///
    func testLockConversionScenario2Example1WaitOnConversionNoQueue() {
        let input = Lock.ResourceID(identifier: "database")

        let requester = DispatchGroup()
        let convert   = DispatchGroup()
        let locked    = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()
        convert.enter()

        DispatchQueue.global().async(group: requester) {

            /// Lock the input so we can convert it later
            XCTAssertEqual(self.locker.lock(input, mode: .U), .granted)

            for _ in 0..<2 {
                locked.enter()

                DispatchQueue.global().async(group: requester) {
                    XCTAssertEqual(self.locker.lock(input, mode: .IS), .granted)

                    locked.leave()   /// Signal that we are locked.
                    cleanup.wait()   /// Wait to cleanup

                    XCTAssertEqual(self.locker.unlock(input), true)
                }
            }
            locked.wait()

            convert.leave()
            XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)

            /// Note: we locked the same resource twice so we need to unlock twice.
            XCTAssertEqual(self.locker.unlock(input), true)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        convert.wait()

        usleep(100)
        cleanup.leave() /// Allow thrads to cleanup.
        requester.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: Exmaple 2 (with conversion queue)

    ///
    /// Given the following lock queue of granted requests with a waiting on conversion queue:
    ///
    /// ```
    /// Lock (U)
    ///   |
    ///   | -> (T1, U, granted) --- (T2, IS, granted) --- (T3, IS, granted) --- (T2, IX, converting)
    /// ```
    ///
    /// `T3` requests up-conversion to `IX` and since `T2` is already waiting, `T3` must also wait resulting in the following queue.
    ///
    /// ```
    /// Lock (U)
    ///   |
    ///   | -> (T1, U, granted) --- (T2, IS, granted) --- (T3, IS, granted) --- (T2, IX, converting) --- (T3, IX, converting)
    /// ```
    ///
    /// `T1` unlocks resulting in `T2` and `T3` being granted the up-conversion since `IS` and `IX` are compatible.
    ///
    /// ```
    /// Lock (IX)
    ///   |
    ///   | -> (T2, IX, granted) --- (T3, IX, granted)
    /// ```
    ///
    func testLockConversionScenario2Example2WaitOnConversionWithConversionQueue() {
        let input = Lock.ResourceID(identifier: "database")

        let requester = DispatchGroup()
        let convert   = DispatchGroup()
        let locked    = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()
        convert.enter()

        DispatchQueue.global().async(group: requester) {

            /// Lock the input in S mode so we can convert it later
            XCTAssertEqual(self.locker.lock(input, mode: .U), .granted)

            for _ in 0..<2 {

                locked.enter()
                DispatchQueue.global().async(group: requester) {
                    XCTAssertEqual(self.locker.lock(input, mode: .IS), .granted)

                    locked.leave()   /// Signal that we are locked.
                    convert.wait()

                    /// Now upgrade the lock
                    XCTAssertEqual(self.locker.lock(input, mode: .IX), .granted)

                    cleanup.wait()   /// Wait to cleanup

                    XCTAssertEqual(self.locker.unlock(input), true)
                    XCTAssertEqual(self.locker.unlock(input), true)
                }
            }
            locked.wait()
            convert.leave()

            usleep(200) /// Sleep to give the X lock a chance to lock.

            XCTAssertEqual(self.locker.unlock(input), true)
        }

        cleanup.leave() /// Allow thrads to cleanup.
        requester.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: Lock scenario 3 (with waiting queue)

    ///
    /// Given the following lock queue of granted and waiting requests:
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | -> (T1, S, granted) --- (T2, S, granted) --- (T3, IX, waiting) --- (T4, IX, waiting)
    /// ```
    ///
    /// If `T1` then requests an up-conversion from `S` to `X`, it will wait and be placed before requests waiting for new locks.
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | -> (T1, S, granted) --- (T2, S, granted) --- (T1, X, converting) --- (T3, IX, waiting) --- (T4, IX, waiting)
    /// ```
    ///
    /// Once `T2` unlocks, `T1` will be granted it's conversion request before the request waiting for new locks are granted.
    ///
    /// ```
    /// Lock (X)
    ///   |
    ///   | -> (T1, X, granted) --- (T3, IX, waiting) --- (T4, IX, waiting)
    /// ```
    ///
    func testLockConversionScenario2Example3WaitOnConversionWithWaitingQueue() {
        let input = Lock.ResourceID(identifier: "database")

        let requester = DispatchGroup()
        let convert   = DispatchGroup()
        let locked    = DispatchGroup()
        let blocked   = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()
        convert.enter()

        locked.enter()
        DispatchQueue.global().async(group: requester) {
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

            locked.leave()   /// Signal that we are locked.
            cleanup.wait()   /// Wait to cleanup

            XCTAssertEqual(self.locker.unlock(input), true)
        }

        locked.enter()
        DispatchQueue.global().async(group: requester) {
            XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

            locked.leave()   /// Signal that we are locked.
            convert.wait()   /// Wait to be Signaled to convert

            /// Now upgrade the lock
            XCTAssertEqual(self.locker.lock(input, mode: .X), .granted)

            cleanup.wait()   /// Wait to cleanup

            XCTAssertEqual(self.locker.unlock(input), true)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        locked.wait()

        for _ in 0..<2 {

            blocked.enter()
            DispatchQueue.global().async(group: requester) {

                blocked.leave()   /// Signal that we are locked.
                XCTAssertEqual(self.locker.lock(input, mode: .IX), .granted)

                cleanup.wait()   /// Wait to cleanup

                XCTAssertEqual(self.locker.unlock(input), true)
            }
        }
        blocked.wait()
        convert.leave()

        usleep(100)
        cleanup.leave() /// Allow thrads to cleanup.
        requester.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: - Lock Scenario 4 (Conversion Deadlock)
    // MARK: Example 1

    ///
    /// Given the lock queue:
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | -> (T1, S, granted) --- (T2, S, granted)
    /// ```
    ///
    /// `T1` and `T2` requests conversion to `X` causing a deadlock
    ///
    /// ```
    /// Lock (S)
    ///   |
    ///   | -> (T1, S, granted) --- (T2, S, granted) --- (T1, X, converting) --- (T2, X, converting)
    /// ```
    ///
    func testLockConversionScenario3Example1Deadlock() {
        let input = Lock.ResourceID(identifier: "database")

        let requester = DispatchGroup()
        let locked    = DispatchGroup()
        let blocked   = DispatchGroup()
        let cleanup   = DispatchGroup()
        cleanup.enter()
        blocked.enter()

        for _ in 0..<2 {

            locked.enter()
            DispatchQueue.global().async(group: requester) {
                XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

                locked.leave()   /// Signal that we are locked.
                blocked.wait()

                /// Now upgrade the lock
                XCTAssertEqual(self.locker.lock(input, mode: .X, timeout: .now() + 0.2), .timeout)

                cleanup.wait()   /// Wait to cleanup

                XCTAssertEqual(self.locker.unlock(input), true)
            }
        }
        locked.wait()
        blocked.leave()

        cleanup.leave() /// Allow thrads to cleanup.
        requester.wait() /// Wait for the background group to finished cleaning up.
    }

    // MARK: - Misc Tests

    func testLockWhenExistingLockThatThreadOwns() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .X), .granted)
        XCTAssertEqual(locker.lock(input, mode: .X), .granted)

        /// Cleanup
        XCTAssertEqual(locker.unlock(input), true)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockPromotionNoContention() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .S), .granted)
        XCTAssertEqual(locker.lock(input, mode: .X, timeout: .now() + 0.1), .granted)

        /// Cleanup
        XCTAssertEqual(locker.unlock(input), true)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible() throws {
        let input = Lock.ResourceID(identifier: "database")
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
        let input = Lock.ResourceID(identifier: "database")

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
        let input = Lock.ResourceID(identifier: "database")

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
        let input = Lock.ResourceID(identifier: "database")

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
        let input = (resourceID1: Lock.ResourceID(identifier: "database"), resourceID2: Lock.ResourceID(identifier: "page"))

        XCTAssertEqual(self.locker.lock(input.resourceID1, mode: .IX), .granted)
        XCTAssertEqual(self.locker.lock(input.resourceID2, mode: .X), .granted)

        XCTAssertEqual(self.locker.unlock(input.resourceID2), true)
        XCTAssertEqual(self.locker.unlock(input.resourceID1), true)
    }

    // MARK: - Round trip tests

    func testLock() throws {
        let input = Lock.ResourceID(identifier: "database")

        XCTAssertEqual(locker.lock(input, mode: .X), .granted)
        XCTAssertEqual(locker.unlock(input), true)
    }

    func testLockUnlockCycle() {
        let input = Lock.ResourceID(identifier: "database")

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
        let input = (resourceID1: Lock.ResourceID(identifier: "database"), resourceID2: Lock.ResourceID(identifier: "page"))

        /// Repeated locks and unlocks
        let group = DispatchGroup()

        for _ in 0..<5 {
            DispatchQueue.global().async(group: group) {
                XCTAssertEqual(self.locker.lock(input.resourceID1, mode: .IX), .granted)
                XCTAssertEqual(self.locker.lock(input.resourceID2, mode: .X), .granted)

                XCTAssertEqual(self.locker.unlock(input.resourceID2), true)
                XCTAssertEqual(self.locker.unlock(input.resourceID1), true)
            }
        }
        group.wait()
    }

    func testLockUnlockCycleRecursiveLocks() {
        let input = (resourceID: Lock.ResourceID(identifier: "database"), lockCount: 5)

        for _ in 0..<input.lockCount {
            XCTAssertEqual(locker.lock(input.resourceID, mode: .X), .granted)
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

                XCTAssertEqual(self.locker.lock(database, mode: .IX), .granted)
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

        let page = Lock.ResourceID(identifier: "page")

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
        XCTAssertEqual(self.locker.unlock(Lock.ResourceID(identifier: "database")), false)
    }
}
