//: [Previous](@previous)

import Dispatch
import StickyLocking

let locker = Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)

let group = DispatchGroup()
group.enter()

/// Lock an incompatible lock on a background thread.
DispatchQueue.global().async {
    _ = locker.lock("MyFile1.txt", mode: .X)
    group.leave()
}
group.wait()

locker.lock("MyFile1.txt", mode: .S, timeout: .now() + 0.1)  /// This will timeout since an X lock is held by another thread
locker.lock("MyFile2.txt", mode: .S)

print(locker)

locker.unlock("MyFile1.txt")    /// This thread has no locks to unlock for MyFile1.txt so this should return false
locker.unlock("MyFile2.txt")

print(locker)
