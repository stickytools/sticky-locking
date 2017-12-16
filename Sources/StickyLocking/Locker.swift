///
///  Locker.swift
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
import Foundation

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD) || os(PS4) || os(Android)  /* Swift 5 support: || os(Cygwin) || os(Haiku) */
    import Glibc
#endif

///
/// The `Locker` class is an implementation of a high concurrency hierarchical lock manager.
///
public class Locker<LockMode: RawRepresentable> where LockMode.RawValue == Lock.Mode {

    ///
    /// Result of requesting a lock on an resource.
    ///
    public enum LockResult {
        case granted
        case denied
        case timeout
    }

    ///
    /// Initialize `self`
    ///
    public init(conflictMatrix: Lock.ConflictMatrix<LockMode>, groupModeMatrix: Lock.GroupModeMatrix<LockMode>) {
        self.lockTable        = [:]
        self.lockTableMutex   = Mutex(.normal)
        self.conflictMatrix   = conflictMatrix
        self.groupModeMatrix = groupModeMatrix
    }

    ///
    /// Lock a resource in `mode`.
    ///
    @discardableResult
    public func lock(_ resource: Lock.ResourceID, mode: LockMode, timeout: WaitTime = WaitTime.distantFuture) -> LockResult {
        let request = Request(mode)

        self.lockTableMutex.lock()

        /// Check for an existing lock entry.
        guard let lock = self.lockTable[resource] else {

            /// If no lock entry, there is no owner so just grant the request.
            let lock = LockEntry(groupMode: mode)
            self.lockTable[resource] = lock

            lock.granted.add(request)

            print("Grant\t\t.\(mode)(.\(lock.groupMode ?? mode))\t-> (resource: \(resource) request: \(request)) no original owner.")   /// TODO: Remove me before production

            self.lockTableMutex.unlock()
            return .granted
        }
        /// -> Lock Exists <-

        /// Crab to the lock mutex, do not unlock the lock table until the lock is locked.
        lock.mutex.lock(); defer { lock.mutex.unlock() }
        self.lockTableMutex.unlock()

        /// The lock is currently owned, do we own this lock?
        if let existing = lock.granted.find(for: request.requester) {

            ///
            /// Existing Lock path.
            ///
            if existing.mode == mode {
                ///
                /// Recursive call for the same owned lock and mode.
                ///
                existing.count += 1 /// Increment the number of locks this owner has

                print("Grant\t\t.\(existing.mode)(.\(lock.groupMode ?? existing.mode))\t-> (resource: \(resource) request: \(existing))") /// TODO: Remove me before production

                return .granted
            }

            ///
            /// Conversion Request
            ///
            /// At this point, we own the lock in some mode and the request is not for that same mode so it's a conversion request.
            ///
            if lock.converting.isEmpty && self.groupModeCompatible(with: request.mode, lock: lock, excluding: existing) {

                existing.count += 1 /// Increment the number of locks this owner has
                existing.mode  = mode
                lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)    /// Upgrade the mode of this lock

                print("Grant^\t\t.\(existing.mode)(.\(lock.groupMode ?? existing.mode))\t-> (resource: \(resource) request: \(existing))") /// TODO: Remove me before production

                return .granted
            }

            ///
            /// Conversion with other waiting conversion requests or other current locks in the queue.
            ///
            lock.converting.add(request)
        } else {

            /// If we get here there are no existing locks and this is not a conversion so we add the request to the end of the queue.
            /// We don't own the lock currently so if there are no waiters and our lock request mode is compatible, we can grant the lock.
            if lock.converting.isEmpty && lock.waiting.isEmpty &&
                self.conflictMatrix.compatible(requested: request.mode, current: lock.groupMode) {

                /// Upgrade the current lock mode.
                lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)

                lock.granted.add(request)

                print("Grant\t\t.\(request.mode)(.\(lock.groupMode ?? request.mode))\t-> (resource: \(resource) request: \(request)) lock request is compatible with current lock.") /// TODO: Remove me before production

                return .granted
            } else {
                lock.waiting.add(request)
            }
        }

        ///
        /// -> Wait <-
        ///
        /// At this point, we need to wait so change the request status and wait.
        ///
        print("Wait\t\t.\(request.mode)\t\t-> (resource: \(resource) request: \(request))") /// TODO: Remove me before production

        while request.waitStatus == nil {    /// Note: the loop protects against **spurious wakeups** because it is the signaler's responsibility to change the status to something other than waiting.
            if request.wait(on: lock.mutex, timeout: timeout) == .timeout {
                request.waitStatus = .timeout
            }
        }

        print("\(self.debugDescription(for: request.waitStatus ?? .denied))\t\t.\(request.mode)(.\(lock.groupMode ?? request.mode))\t-> (resource: \(resource) request: \(request))")

        switch request.waitStatus {     /// Translate RequestStatus to LockResult
        case .granted?:
            return .granted

        case .timeout?:
            lock.converting.remove(request)
            lock.waiting.remove(request)

            return .timeout
        default:
            lock.converting.remove(request)
            lock.waiting.remove(request)

            return .denied
        }
    }

    ///
    /// Unlock the resource.
    ///
    @discardableResult
    public func unlock(_ resource: Lock.ResourceID) -> Bool {
        let requester = Requester()

        self.lockTableMutex.lock()

        guard let lock = self.lockTable[resource] else {
            self.lockTableMutex.unlock()
            return false
        }

        lock.mutex.lock(); defer { lock.mutex.unlock() }

        ///
        /// Handle the case where there is an existing lock that is already granted for this requester.
        ///
        if let existing = lock.granted.find(for: requester) {

            print("Unlocked\t.\(existing.mode)(.\(lock.groupMode ?? existing.mode))\t-> (resource: \(resource) request: \(existing))") /// TODO: Remove me before production

            existing.count -= 1    /// Decrement the count for this owner.

            if existing.count > 0 {
                self.lockTableMutex.unlock()
                return true     /// Only need to decrement lock and return.
            }
            /// If the number of times this lock was acquired is zero, we can remove it from the queue.
            lock.granted.remove(existing)
            lock.groupMode = nil
        }

        /// If the queue count is now zero, we can remove the entire entry because there are no conversions, waiters or lockers.
        if lock.granted.isEmpty && lock.converting.isEmpty && lock.waiting.isEmpty {
            self.lockTable[resource] = nil      /// No requester and no waiters, deallocate the lock structure and exit.
            self.lockTableMutex.unlock()
            return true
        }

        /// We don't require the lockTable locked from this point on.
        self.lockTableMutex.unlock()

        /// Update the group mode
        for request in lock.granted {

            /// If already granted, we need to realigned (possibly downgrade) the group mode of the current lock.
            lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)
        }

        ///
        /// -> Handle waiters <-
        ///
        /// if there are any waiters, grant the lock to the next one (FIFO order).
        ///
        /// Note: Make sure the lockTableMutex is unlocked by the time you go into this loop.
        ///
        for request in lock.converting {
            if let existing = lock.granted.find(for: request.requester),
                self.groupModeCompatible(with: request.mode, lock: lock, excluding: existing) {

                /// Upgrade the lock mode
                lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)

                lock.converting.remove(request) /// Remove the conversion request from the queue
                request.waitStatus = .granted

                existing.mode = request.mode
                existing.count += 1 /// A conversion increments the lock count.

                request.signal()   /// Signal the waiter that the request status has changed
            } else {
                return true
            }
        }

        for request in lock.waiting {
            if self.conflictMatrix.compatible(requested: request.mode, current: lock.groupMode) {

                /// Upgrade the lock mode
                lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)

                lock.waiting.remove(request)
                lock.granted.add(request)
                request.waitStatus = .granted

                request.signal()   /// Signal the waiter that the request status has changed
            } else {
                return true
            }
        }
        return true
    }

    @inline(__always)
    private func groupModeCompatible(with requestedMode: LockMode, lock: LockEntry, excluding: Request) -> Bool {
        let groupMode: LockMode? = self.groupMode(excluding: excluding, lock: lock)

        return groupMode == nil ? true : self.conflictMatrix.compatible(requested: requestedMode, current: groupMode)
    }

    @inline(__always)
    private func groupMode(excluding: Request, lock: LockEntry) -> LockMode? {
        var groupMode: LockMode? = nil

        for request in lock.granted {
            if request != excluding {
                groupMode = self.groupModeMatrix.convert(requested: request.mode, current: groupMode)
            }
        }
        return groupMode
    }

    @inline(__always)
    private func debugDescription(for status: Request.Status) -> String {
        switch status {
        case .granted: return "Grant"
        case .denied:  return "Denied"
        case .timeout: return "Timeout"
        }
    }

    private let lockTableMutex: Mutex                             /// Mutex for locking the the critical section.
    private var lockTable: [Lock.ResourceID: LockEntry]           /// Lock table containing all active locks.
    private var conflictMatrix: Lock.ConflictMatrix<LockMode>     /// Matrix used to determine access when 2 or more locks exist.
    private var groupModeMatrix: Lock.GroupModeMatrix<LockMode> /// Matrix used when converting a lock (eg S -> X)
}

private extension Locker {

    ///
    /// Lock value class which represents a granted lock.
    ///
    private class LockEntry{

        init(groupMode: LockMode? = nil) {
            self.groupMode = groupMode
            self.granted    = RequestQueue()
            self.converting = RequestQueue()
            self.waiting    = RequestQueue()
            self.mutex      = Mutex()
        }

        var groupMode:  LockMode?
        var granted:    RequestQueue
        var converting: RequestQueue
        var waiting:    RequestQueue

        let mutex: Mutex                /// Mutex for locking while maintaining owners and waiters as well as waiting on the lock with a condition.
    }
}
