//: [Previous](@previous)

import StickyLocking


let locker = Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)

locker.lock("MyFile1.txt", mode: .S)
locker.lock("MyFile1.txt", mode: .X)     /// Lock is granted because the S lock is upgrade to an X lock
locker.lock("MyFile2.txt", mode: .S)

print(locker)

locker.unlock("MyFile1.txt")
locker.unlock("MyFile2.txt")
locker.unlock("MyFile1.txt")

print(locker)
