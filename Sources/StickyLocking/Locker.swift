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
public class Locker<T: RawRepresentable> where T.RawValue == LockMode {

    ///
    /// Initialize `self` with the given `CompatibilityMatrix` and `GroupModeMatrix`.
    ///
    /// - Parameters:
    ///   - compatibilityMatrix: The `CompatibilityMatrix` to use for determining lock compatibility.
    ///   - groupModeMatrix: The `GroupModeMatrix` to use when determining the group mode of the granted locks and the group mode of a new request given an existing group mode.
    ///
    public init(compatibilityMatrix: CompatibilityMatrix<T>, groupModeMatrix: GroupModeMatrix<T>) {
        self.lockTable              = [:]
        self.lockTableMutex         = Mutex(.normal)
        self.compatibilityMatrix    = compatibilityMatrix
        self.groupModeMatrix        = groupModeMatrix
    }

    ///
    /// Lock a resource in the given `mode`.
    ///
    /// - Parameters:
    ///   - resource: The `Hashable` resource to lock.
    ///   - mode: The `LockMode` to lock the `resource` in.
    ///   - timeout: An optional timeout period to wait for the lock to be granted before giving up and returning `RequestStatus.timeout`
    ///
    /// - Returns: `RequestStatus.granted` when the lock is granted, `.denied` if the lock can not be granted before the timeout, or `.timeout` if the request could not be granted before the timeout period expired.
    ///
    @discardableResult
    public func lock<R: Hashable>(_ resource: R, mode: T, timeout: WaitTime = WaitTime.distantFuture) -> RequestStatus {
        let request = Request(mode)

        self.lockTableMutex.lock()

        /// Check for an existing lock entry.
        guard let lock = self.lockTable[resource] else {

            /// If no lock entry, there is no owner so just grant the request.
            let lock = LockEntry(groupMode: mode)
            self.lockTable[resource] = lock

            lock.granted.add(request)
#if DEBUG
            print("\(RequestStatus.granted)\t\t.\(mode)(.\(lock.groupMode ?? mode))\t-> (resource: \(resource) request: \(request)) no original owner.")   /// TODO: Remove me before production
#endif
            self.lockTableMutex.unlock()
            return .granted
        }
        /// --> Lock Exists <--

        /// Crab to the lock mutex, do not unlock the lock table until the lock is locked.
        lock.mutex.lock(); defer { lock.mutex.unlock() }
        self.lockTableMutex.unlock()

        /// The lock is currently owned, do we own this lock?
        if let existing = lock.granted.find(for: request.requester) {
            ///
            /// --> The requester owns the existing lock <--
            ///

            /// Is the existing lock the same mode as the requested lock? This condition
            /// indicates a recursive call which is the requester requesting the same
            /// lock multiple times.
            if existing.mode == mode {
                ///
                /// --> Recursive call for the same owned lock and mode <--
                ///
                existing.count += 1 /// Increment the number of locks this owner has
#if DEBUG
                print("\(RequestStatus.granted)\t\t.\(existing.mode)(.\(lock.groupMode ?? existing.mode))\t-> (resource: \(resource) request: \(existing))") /// TODO: Remove me before production
#endif
                return .granted
            }

            ///
            /// --> Conversion Request <---
            ///
            /// At this point, we own the lock but the request is not for that same mode so it's a conversion request.
            ///

            /// If no other conversions are waiting and the lock mode is compatible with the existing group mode, we can grant the lock.
            if lock.converting.isEmpty && self.grantedGroupModeCompatible(with: request.mode, lock: lock, excluding: existing) {

                existing.count += 1 /// Increment the number of locks this owner has
                existing.mode  = mode
                lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)    /// Upgrade the mode of this lock
#if DEBUG
                print("\(RequestStatus.granted)^\t\t.\(existing.mode)(.\(lock.groupMode ?? existing.mode))\t-> (resource: \(resource) request: \(existing))") /// TODO: Remove me before production
#endif
                return .granted
            }

            /// --> Conversion must wait <---

            lock.converting.add(request)

        } else {
            ///
            /// --> The requester does NOT own the existing lock <--
            ///

            /// We don't own the lock currently so if there are no waiters and our lock request mode is compatible, we can grant the lock.
            if lock.converting.isEmpty && lock.waiting.isEmpty &&
                self.compatibilityMatrix.compatible(requested: request.mode, current: lock.groupMode) {

                /// Upgrade the current lock mode.
                lock.groupMode = groupModeMatrix.convert(requested: request.mode, current: lock.groupMode)

                lock.granted.add(request)
#if DEBUG
                print("\(RequestStatus.granted)\t\t.\(request.mode)(.\(lock.groupMode ?? request.mode))\t-> (resource: \(resource) request: \(request)) lock request is compatible with current lock.") /// TODO: Remove me before production
#endif
                return .granted
            } else {

                /// --> Request must wait <--

                lock.waiting.add(request)
            }
        }

        ///
        /// --> Begin Wait <--
        ///
        /// At this point, we need to wait so change the request status and wait.
        ///
#if DEBUG
        print("wait\t\t.\(request.mode)\t\t-> (resource: \(resource) request: \(request))") /// TODO: Remove me before production
#endif
        while request.waitStatus == nil {    /// Note: the loop protects against **spurious wakeups** because it is the signaler's responsibility to change the status to something other than waiting.
            if request.wait(on: lock.mutex, timeout: timeout) == .timeout {
                request.waitStatus = .timeout
            }
        }
        /// --> End Wait <--

#if DEBUG
        print("\(request.waitStatus ?? .denied)\t\t.\(request.mode)(.\(lock.groupMode ?? request.mode))\t-> (resource: \(resource) request: \(request))")
#endif
        switch request.waitStatus {
        case .granted?:
            /// no-op
                break

        case .timeout?:
            lock.converting.remove(request)
            lock.waiting.remove(request)
        default:
            lock.converting.remove(request)
            lock.waiting.remove(request)
        }
        return request.waitStatus ?? .denied
    }

    ///
    /// Unlock the resource.
    ///
    /// - Parameter resource: The `ResourceID` to unlock.
    ///
    /// - Returns: `true` if the resource was unlocked, `false` otherwise.
    ///
    @discardableResult
    public func unlock<R: Hashable>(_ resource: R) -> Bool {
        let requester = Requester()

        self.lockTableMutex.lock()

        guard let lock = self.lockTable[resource],
              let existing = lock.granted.find(for: requester) else {
                self.lockTableMutex.unlock()
                return false
            }

        lock.mutex.lock(); defer { lock.mutex.unlock() }

        existing.count -= 1    /// Decrement the count for this owner.
#if DEBUG
        print("unlocked\t.\(existing.mode)(.\(lock.groupMode ?? existing.mode))\t-> (resource: \(resource) request: \(existing))") /// TODO: Remove me before production
#endif
        /// If the count is greater than zero, this lock is still held and we just exit since we've already decremented the count.
        if existing.count > 0 {
            self.lockTableMutex.unlock()
            return true     /// Only need to decrement lock and return.
        }

        lock.granted.remove(existing)
        lock.groupMode = nil

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
        /// Note: Make sure the lockTableMutex is unlocked before handling conversions and waiters below.
        ///

        ///
        /// -> Handle Conversions <-
        ///
        /// If there are any conversions waiting that are compatible, grant the lock to the next one (FIFO order).
        ///
        for request in lock.converting {
            if let existing = lock.granted.find(for: request.requester),
                self.grantedGroupModeCompatible(with: request.mode, lock: lock, excluding: existing) {

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

        ///
        /// -> Handle waiters <-
        ///
        /// If there are any waiters waiting that are compatible, grant the lock to the next one (FIFO order).
        ///
        for request in lock.waiting {
            if self.compatibilityMatrix.compatible(requested: request.mode, current: lock.groupMode) {

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

    private let lockTableMutex: Mutex                        /// Mutex for locking the the critical section.
    private var lockTable: [AnyHashable: LockEntry]          /// Lock table containing all active locks.
    private var compatibilityMatrix: CompatibilityMatrix<T>  /// Matrix used to determine access when 2 or more locks exist.
    private var groupModeMatrix: GroupModeMatrix<T>          /// Matrix used when converting a lock (eg S -> X)
}

extension Locker: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return "Locker(\(lockTable.description))"
    }

    public var debugDescription: String {
        return self.description
    }
}

private extension Locker {

    ///
    /// Lock value class which represents a granted lock.
    ///
    private class LockEntry: CustomStringConvertible, CustomDebugStringConvertible {

        var groupMode:  T?
        var granted:    RequestQueue
        var converting: RequestQueue
        var waiting:    RequestQueue

        let mutex: Mutex                /// Mutex for locking while maintaining owners and waiters as well as waiting on the lock with a condition.

        init(groupMode: T? = nil) {
            self.groupMode  = groupMode
            self.granted    = RequestQueue()
            self.converting = RequestQueue()
            self.waiting    = RequestQueue()
            self.mutex      = Mutex()
        }

        var description: String {
            let modeString: String

            if let mode = self.groupMode {
                modeString = "\(mode)"
            } else {
                modeString = "nil"
            }

            return """
                LockEntry(.\(modeString),\r
                \t\t     granted: \(self.granted),\r
                \t\t  converting: \(self.converting),\r
                \t\t     waiting: \(self.waiting)\r
                \t\t)
                """
        }

        var debugDescription: String {
            return self.description
        }
    }

    ///
    /// Test whether the requested mode is compatible with the current group mode calculate
    /// by removing the `excluding` requests mode.
    ///
    ///
    /// - Parameters:
    ///   - requestedMode: The mode being tested for compatibility with the group.
    ///   - lock: The lockEntry to perform the test on using the granted group of the entry.
    ///   - excluding: The `Request` to exclude from the granted group while calculating the granted group mode.
    ///
    /// - Returns: Whether the requested mode is compatible with the current granted group mode calculated after removing the `excluding` Request from the granted group.
    ///
    @inline(__always)
    private func grantedGroupModeCompatible(with requestedMode: T, lock: LockEntry, excluding: Request) -> Bool {
        let groupMode: T? = self.grantedGroupMode(of: lock, excluding: excluding)

        return groupMode == nil ? true : self.compatibilityMatrix.compatible(requested: requestedMode, current: groupMode)
    }

    ///
    /// Calculates the **granted** group mode excluding a specific entry. Used to exclude the
    /// existing mode from the calculation ensuring a mode request can be converted to itself.
    ///
    /// - Example: 1 (Multiple existing granted requests)
    ///
    ///     Existing Request = R1
    ///     ```
    ///     Lock (U)    <- Existing Group Mode
    ///        |
    ///        | granted ->  (R1, U) --- (R2, IS) --- (R3, IS)
    ///                         ^
    ///                         |
    ///                     Remove R1
    ///     ```
    ///     Calculate the granted Group mode on remaining requests
    ///     ```
    ///        IS + IS = IS
    ///     ```
    /// - Example: 2 (Only the `excluding` request in the granted queue)
    ///
    ///     Existing Request = R1
    ///     ```
    ///     Lock (U)    <- Existing Group Mode
    ///        |
    ///        | granted ->  (R1, U)
    ///                         ^
    ///                         |
    ///                     Remove R1
    ///     ```
    ///     Calculate the granted Group mode on remaining requests
    ///     ```
    ///        nil = nil
    ///     ```
    /// - Parameters:
    ///     - lock: The lockEntry to perform the calculartion on using the granted group of the entry.
    ///     - excluding: The `Request` to exclude from the granted group while calculating the granted group mode.
    ///
    /// - Returns: The group mode calculated after removing the `excluding` Request from the granted group or nil if there are no granted requests after removing `excluding`.
    ///
    @inline(__always)
    private func grantedGroupMode(of lock: LockEntry, excluding: Request) -> T? {
        var groupMode: T? = nil

        for request in lock.granted {
            if request != excluding {
                groupMode = self.groupModeMatrix.convert(requested: request.mode, current: groupMode)
            }
        }
        return groupMode
    }
}
