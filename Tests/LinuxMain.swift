
/// build-tools: auto-generated

#if os(Linux) || os(FreeBSD)

import XCTest

@testable import StickyLockingTests

XCTMain([
   testCase(Lock_ModeTests.allTests),
   testCase(MutexTests.allTests),
   testCase(ConditionTests.allTests),
   testCase(LockGroupModeMatrixTests.allTests),
   testCase(LockerUnrestrictedCompatibilityMatrixTests.allTests),
   testCase(WaitTimeTests.allTests),
   testCase(LockerRequesterTests.allTests),
   testCase(LockerRequestQueueTests.allTests),
   testCase(LockerSharedExclusiveLockModeTests.allTests),
   testCase(LockerRequestTests.allTests),
   testCase(Lock_CompatibilityMatrixTests.allTests),
   testCase(ExtendedLockModeTests.allTests),
   testCase(LockerExtendedLockModeTests.allTests)
])

extension Lock_ModeTests {
   static var allTests: [(String, (Lock_ModeTests) -> () throws -> Void)] {
      return [
                ("testInit", testInit),
                ("testEqualTrue", testEqualTrue),
                ("testEqualFalse", testEqualFalse),
                ("testDescription", testDescription),
                ("testDebugDescription", testDebugDescription)
           ]
   }
}

extension MutexTests {
   static var allTests: [(String, (MutexTests) -> () throws -> Void)] {
      return [
                ("testLockUnlock", testLockUnlock),
                ("testLockUnlockRecursive", testLockUnlockRecursive),
                ("testLockUnlockNonRecursiveBlocked", testLockUnlockNonRecursiveBlocked),
                ("testLockBlocked", testLockBlocked),
                ("testTryLockBlocked", testTryLockBlocked)
           ]
   }
}

extension ConditionTests {
   static var allTests: [(String, (ConditionTests) -> () throws -> Void)] {
      return [
                ("testWait", testWait),
                ("testWaitWithTimeout", testWaitWithTimeout),
                ("testWaitWithTimeOutSignaled", testWaitWithTimeOutSignaled)
           ]
   }
}

extension LockGroupModeMatrixTests {
   static var allTests: [(String, (LockGroupModeMatrixTests) -> () throws -> Void)] {
      return [
                ("testInitAndCompatible", testInitAndCompatible),
                ("testDescription", testDescription),
                ("testDebugDescription", testDebugDescription)
           ]
   }
}

extension LockerUnrestrictedCompatibilityMatrixTests {
   static var allTests: [(String, (LockerUnrestrictedCompatibilityMatrixTests) -> () throws -> Void)] {
      return [
                ("testLockWhenExistingLock", testLockWhenExistingLock)
           ]
   }
}

extension WaitTimeTests {
   static var allTests: [(String, (WaitTimeTests) -> () throws -> Void)] {
      return [
                ("testNow", testNow),
                ("testAdd1Second", testAdd1Second),
                ("testAdd1NanoSecondRollingTo1Second", testAdd1NanoSecondRollingTo1Second),
                ("testAdd1Second1NanoSecondRollingTo2Seconds", testAdd1Second1NanoSecondRollingTo2Seconds),
                ("testAddNegative1NanoSecondRollingTo0NanoSeconds", testAddNegative1NanoSecondRollingTo0NanoSeconds),
                ("testAddNegative1Second1NanoSecondRollingTo2Seconds", testAddNegative1Second1NanoSecondRollingTo2Seconds),
                ("testEqualTrue", testEqualTrue),
                ("testEqualFalse", testEqualFalse)
           ]
   }
}

extension LockerRequesterTests {
   static var allTests: [(String, (LockerRequesterTests) -> () throws -> Void)] {
      return [
                ("testInit", testInit),
                ("testEqualTrue", testEqualTrue),
                ("testEqualFalse", testEqualFalse),
                ("testDescription", testDescription),
                ("testDebugDescription", testDebugDescription)
           ]
   }
}

extension LockerRequestQueueTests {
   static var allTests: [(String, (LockerRequestQueueTests) -> () throws -> Void)] {
      return [
                ("testCount", testCount),
                ("testCountAfterRemoval", testCountAfterRemoval),
                ("testFindTrue", testFindTrue),
                ("testFindFalse", testFindFalse),
                ("testAdd", testAdd),
                ("testRemove", testRemove),
                ("testRemoveNonExisting", testRemoveNonExisting)
           ]
   }
}

extension LockerSharedExclusiveLockModeTests {
   static var allTests: [(String, (LockerSharedExclusiveLockModeTests) -> () throws -> Void)] {
      return [
                ("testInit", testInit),
                ("testLockWhenNoOtherLocks", testLockWhenNoOtherLocks),
                ("testLockWhenExistingLockThatThreadOwns", testLockWhenExistingLockThatThreadOwns),
                ("testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible", testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible),
                ("testLockWhenExistingIncompatibleLockForcesWait", testLockWhenExistingIncompatibleLockForcesWait),
                ("testLockWhenExistingIncompatibleLockForcesWaitWithTimeout", testLockWhenExistingIncompatibleLockForcesWaitWithTimeout),
                ("testLockWhenExistingIncompatibleLockAllowingTimeout", testLockWhenExistingIncompatibleLockAllowingTimeout),
                ("testLockMultipleResourcesOnSameThread", testLockMultipleResourcesOnSameThread),
                ("testLock", testLock),
                ("testLockUnlockCycle", testLockUnlockCycle),
                ("testLockUnlockCycleMultipleLocks", testLockUnlockCycleMultipleLocks),
                ("testLockUnlockCycleRecursiveLocks", testLockUnlockCycleRecursiveLocks),
                ("testLockUnlockCycleMultipleLocksNonConflicting", testLockUnlockCycleMultipleLocksNonConflicting),
                ("testLockUnlockCycleCompatibleLockMultipleLockers", testLockUnlockCycleCompatibleLockMultipleLockers),
                ("testUnlockWhenNothingLocked", testUnlockWhenNothingLocked),
                ("testUnlockWhenLockNotOwnedByRequester", testUnlockWhenLockNotOwnedByRequester)
           ]
   }
}

extension LockerRequestTests {
   static var allTests: [(String, (LockerRequestTests) -> () throws -> Void)] {
      return [
                ("testInit", testInit),
                ("testInitWithDefaultLockerValue", testInitWithDefaultLockerValue),
                ("testInitWithLocker", testInitWithLocker),
                ("testStatusDefaultValue", testStatusDefaultValue),
                ("testCountDefaultValue", testCountDefaultValue),
                ("testMode", testMode),
                ("testCountIncrementAssign", testCountIncrementAssign),
                ("testWaitSignal", testWaitSignal),
                ("testDescription", testDescription),
                ("testDebugDescription", testDebugDescription)
           ]
   }
}

extension Lock_CompatibilityMatrixTests {
   static var allTests: [(String, (Lock_CompatibilityMatrixTests) -> () throws -> Void)] {
      return [
                ("testInitAndCompatible", testInitAndCompatible),
                ("testDescription", testDescription),
                ("testDebugDescription", testDebugDescription)
           ]
   }
}

extension ExtendedLockModeTests {
   static var allTests: [(String, (ExtendedLockModeTests) -> () throws -> Void)] {
      return [
                ("testInitArrayLiteral", testInitArrayLiteral),
                ("testDefaultMatrix", testDefaultMatrix),
                ("testDescription", testDescription),
                ("testDebugDescription", testDebugDescription)
           ]
   }
}

extension LockerExtendedLockModeTests {
   static var allTests: [(String, (LockerExtendedLockModeTests) -> () throws -> Void)] {
      return [
                ("testInit", testInit),
                ("testLockGrantWhenNoOtherLocks", testLockGrantWhenNoOtherLocks),
                ("testLockWaitScenario1NotCompatibleWithGroupMode", testLockWaitScenario1NotCompatibleWithGroupMode),
                ("testLockWaitScenario2ExistingWaitingRequests", testLockWaitScenario2ExistingWaitingRequests),
                ("testLockWaitScenario3ExistingConversionRequests", testLockWaitScenario3ExistingConversionRequests),
                ("testLockConversionScenario1Example1ImmediateConversion", testLockConversionScenario1Example1ImmediateConversion),
                ("testLockConversionScenario1Example2ImmediateConversionWithWaitQueue", testLockConversionScenario1Example2ImmediateConversionWithWaitQueue),
                ("testLockConversionScenario2Example1WaitOnConversionNoQueue", testLockConversionScenario2Example1WaitOnConversionNoQueue),
                ("testLockConversionScenario2Example2WaitOnConversionWithConversionQueue", testLockConversionScenario2Example2WaitOnConversionWithConversionQueue),
                ("testLockConversionScenario2Example3WaitOnConversionWithWaitingQueue", testLockConversionScenario2Example3WaitOnConversionWithWaitingQueue),
                ("testLockConversionScenario3Example1Deadlock", testLockConversionScenario3Example1Deadlock),
                ("testLockWhenExistingLockThatThreadOwns", testLockWhenExistingLockThatThreadOwns),
                ("testLockPromotionNoContention", testLockPromotionNoContention),
                ("testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible", testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible),
                ("testLockWhenExistingIncompatibleLockForcesWait", testLockWhenExistingIncompatibleLockForcesWait),
                ("testLockWhenExistingIncompatibleLockForcesWaitWithTimeout", testLockWhenExistingIncompatibleLockForcesWaitWithTimeout),
                ("testLockWhenExistingIncompatibleLockAllowingTimeout", testLockWhenExistingIncompatibleLockAllowingTimeout),
                ("testLockMultipleResourcesOnSameThread", testLockMultipleResourcesOnSameThread),
                ("testLock", testLock),
                ("testLockUnlockCycle", testLockUnlockCycle),
                ("testLockUnlockCycleMultipleLocks", testLockUnlockCycleMultipleLocks),
                ("testLockUnlockCycleRecursiveLocks", testLockUnlockCycleRecursiveLocks),
                ("testLockUnlockCycleMultipleLocksNonConflicting", testLockUnlockCycleMultipleLocksNonConflicting),
                ("testLockUnlockCycleCompatibleLockMultipleLockers", testLockUnlockCycleCompatibleLockMultipleLockers),
                ("testUnlockWhenNothingLocked", testUnlockWhenNothingLocked),
                ("testUnlockWhenLockNotOwnedByRequester", testUnlockWhenLockNotOwnedByRequester)
           ]
   }
}

#endif
