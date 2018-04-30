//: [Previous](@previous)

import Dispatch
import StickyLocking

let locker = Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)

let group = DispatchGroup()
group.enter()

/// Lock an incompatible lock on a background thread.
DispatchQueue.global().async {
    _ = locker.lock("MyFile1.txt", mode: .S)
    group.leave()
}
group.wait()

locker.lock("MyFile1.txt", mode: .S)
locker.lock("MyFile1.txt", mode: .S)

locker.lock("MyFile2.txt", mode: .S)

print(locker)

locker.unlock("MyFile1.txt")
locker.unlock("MyFile1.txt")

locker.unlock("MyFile2.txt")

print(locker)
