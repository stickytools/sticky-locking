import XCTest

extension ConditionTests {
    static let __allTests = [
        ("testWait", testWait),
        ("testWaitWithTimeout", testWaitWithTimeout),
        ("testWaitWithTimeOutSignaled", testWaitWithTimeOutSignaled),
    ]
}

extension DocumentationExampleTests {
    static let __allTests = [
        ("testSimpleLockerCreation", testSimpleLockerCreation),
    ]
}

extension ExtendedLockModeTests {
    static let __allTests = [
        ("testDebugDescription", testDebugDescription),
        ("testDefaultMatrix", testDefaultMatrix),
        ("testDescription", testDescription),
        ("testInitArrayLiteral", testInitArrayLiteral),
    ]
}

extension LockGroupModeMatrixTests {
    static let __allTests = [
        ("testDebugDescription", testDebugDescription),
        ("testDescription", testDescription),
        ("testInitAndCompatible", testInitAndCompatible),
    ]
}

extension Lock_CompatibilityMatrixTests {
    static let __allTests = [
        ("testDebugDescription", testDebugDescription),
        ("testDescription", testDescription),
        ("testInitAndCompatible", testInitAndCompatible),
    ]
}

extension Lock_ModeTests {
    static let __allTests = [
        ("testDebugDescription", testDebugDescription),
        ("testDescription", testDescription),
        ("testEqualFalse", testEqualFalse),
        ("testEqualTrue", testEqualTrue),
        ("testInit", testInit),
    ]
}

extension LockerExtendedLockModeTests {
    static let __allTests = [
        ("testInit", testInit),
        ("testLock", testLock),
        ("testLockConversionScenario1Example1ImmediateConversion", testLockConversionScenario1Example1ImmediateConversion),
        ("testLockConversionScenario1Example2ImmediateConversionWithWaitQueue", testLockConversionScenario1Example2ImmediateConversionWithWaitQueue),
        ("testLockConversionScenario2Example1WaitOnConversionNoQueue", testLockConversionScenario2Example1WaitOnConversionNoQueue),
        ("testLockConversionScenario2Example2WaitOnConversionWithConversionQueue", testLockConversionScenario2Example2WaitOnConversionWithConversionQueue),
        ("testLockConversionScenario2Example3WaitOnConversionWithWaitingQueue", testLockConversionScenario2Example3WaitOnConversionWithWaitingQueue),
        ("testLockConversionScenario3Example1Deadlock", testLockConversionScenario3Example1Deadlock),
        ("testLockGrantWhenNoOtherLocks", testLockGrantWhenNoOtherLocks),
        ("testLockMultipleResourcesOnSameThread", testLockMultipleResourcesOnSameThread),
        ("testLockPromotionNoContention", testLockPromotionNoContention),
        ("testLockUnlockCycle", testLockUnlockCycle),
        ("testLockUnlockCycleCompatibleLockMultipleLockers", testLockUnlockCycleCompatibleLockMultipleLockers),
        ("testLockUnlockCycleMultipleLocks", testLockUnlockCycleMultipleLocks),
        ("testLockUnlockCycleMultipleLocksNonConflicting", testLockUnlockCycleMultipleLocksNonConflicting),
        ("testLockUnlockCycleRecursiveLocks", testLockUnlockCycleRecursiveLocks),
        ("testLockWaitScenario1NotCompatibleWithGroupMode", testLockWaitScenario1NotCompatibleWithGroupMode),
        ("testLockWaitScenario2ExistingWaitingRequests", testLockWaitScenario2ExistingWaitingRequests),
        ("testLockWaitScenario3ExistingConversionRequests", testLockWaitScenario3ExistingConversionRequests),
        ("testLockWhenExistingIncompatibleLockAllowingTimeout", testLockWhenExistingIncompatibleLockAllowingTimeout),
        ("testLockWhenExistingIncompatibleLockForcesWait", testLockWhenExistingIncompatibleLockForcesWait),
        ("testLockWhenExistingIncompatibleLockForcesWaitWithTimeout", testLockWhenExistingIncompatibleLockForcesWaitWithTimeout),
        ("testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible", testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible),
        ("testLockWhenExistingLockThatThreadOwns", testLockWhenExistingLockThatThreadOwns),
        ("testUnlockWhenLockNotOwnedByRequester", testUnlockWhenLockNotOwnedByRequester),
        ("testUnlockWhenNothingLocked", testUnlockWhenNothingLocked),
    ]
}

extension LockerRequestQueueTests {
    static let __allTests = [
        ("testAdd", testAdd),
        ("testCount", testCount),
        ("testCountAfterRemoval", testCountAfterRemoval),
        ("testFindFalse", testFindFalse),
        ("testFindTrue", testFindTrue),
        ("testRemove", testRemove),
        ("testRemoveNonExisting", testRemoveNonExisting),
    ]
}

extension LockerRequestTests {
    static let __allTests = [
        ("testCountDefaultValue", testCountDefaultValue),
        ("testCountIncrementAssign", testCountIncrementAssign),
        ("testDebugDescription", testDebugDescription),
        ("testDescription", testDescription),
        ("testInit", testInit),
        ("testInitWithDefaultLockerValue", testInitWithDefaultLockerValue),
        ("testInitWithLocker", testInitWithLocker),
        ("testMode", testMode),
        ("testStatusDefaultValue", testStatusDefaultValue),
        ("testWaitSignal", testWaitSignal),
    ]
}

extension LockerRequesterTests {
    static let __allTests = [
        ("testDebugDescription", testDebugDescription),
        ("testDescription", testDescription),
        ("testEqualFalse", testEqualFalse),
        ("testEqualTrue", testEqualTrue),
        ("testInit", testInit),
    ]
}

extension LockerSharedExclusiveLockModeTests {
    static let __allTests = [
        ("testInit", testInit),
        ("testLock", testLock),
        ("testLockMultipleResourcesOnSameThread", testLockMultipleResourcesOnSameThread),
        ("testLockUnlockCycle", testLockUnlockCycle),
        ("testLockUnlockCycleCompatibleLockMultipleLockers", testLockUnlockCycleCompatibleLockMultipleLockers),
        ("testLockUnlockCycleMultipleLocks", testLockUnlockCycleMultipleLocks),
        ("testLockUnlockCycleMultipleLocksNonConflicting", testLockUnlockCycleMultipleLocksNonConflicting),
        ("testLockUnlockCycleRecursiveLocks", testLockUnlockCycleRecursiveLocks),
        ("testLockWhenExistingIncompatibleLockAllowingTimeout", testLockWhenExistingIncompatibleLockAllowingTimeout),
        ("testLockWhenExistingIncompatibleLockForcesWait", testLockWhenExistingIncompatibleLockForcesWait),
        ("testLockWhenExistingIncompatibleLockForcesWaitWithTimeout", testLockWhenExistingIncompatibleLockForcesWaitWithTimeout),
        ("testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible", testLockWhenExistingLockThatThreadDoesNotOwnButIsCompatible),
        ("testLockWhenExistingLockThatThreadOwns", testLockWhenExistingLockThatThreadOwns),
        ("testLockWhenNoOtherLocks", testLockWhenNoOtherLocks),
        ("testUnlockWhenLockNotOwnedByRequester", testUnlockWhenLockNotOwnedByRequester),
        ("testUnlockWhenNothingLocked", testUnlockWhenNothingLocked),
    ]
}

extension LockerUnrestrictedCompatibilityMatrixTests {
    static let __allTests = [
        ("testLockWhenExistingLock", testLockWhenExistingLock),
    ]
}

extension MutexTests {
    static let __allTests = [
        ("testLockBlocked", testLockBlocked),
        ("testLockUnlock", testLockUnlock),
        ("testLockUnlockNonRecursiveBlocked", testLockUnlockNonRecursiveBlocked),
        ("testLockUnlockRecursive", testLockUnlockRecursive),
        ("testTryLockBlocked", testTryLockBlocked),
    ]
}

extension WaitTimeTests {
    static let __allTests = [
        ("testAdd1NanoSecondRollingTo1Second", testAdd1NanoSecondRollingTo1Second),
        ("testAdd1Second", testAdd1Second),
        ("testAdd1Second1NanoSecondRollingTo2Seconds", testAdd1Second1NanoSecondRollingTo2Seconds),
        ("testAddNegative1NanoSecondRollingTo0NanoSeconds", testAddNegative1NanoSecondRollingTo0NanoSeconds),
        ("testAddNegative1Second1NanoSecondRollingTo2Seconds", testAddNegative1Second1NanoSecondRollingTo2Seconds),
        ("testEqualFalse", testEqualFalse),
        ("testEqualTrue", testEqualTrue),
        ("testNow", testNow),
    ]
}

#if !canImport(ObjectiveC)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ConditionTests.__allTests),
        testCase(DocumentationExampleTests.__allTests),
        testCase(ExtendedLockModeTests.__allTests),
        testCase(LockGroupModeMatrixTests.__allTests),
        testCase(Lock_CompatibilityMatrixTests.__allTests),
        testCase(Lock_ModeTests.__allTests),
        testCase(LockerExtendedLockModeTests.__allTests),
        testCase(LockerRequestQueueTests.__allTests),
        testCase(LockerRequestTests.__allTests),
        testCase(LockerRequesterTests.__allTests),
        testCase(LockerSharedExclusiveLockModeTests.__allTests),
        testCase(LockerUnrestrictedCompatibilityMatrixTests.__allTests),
        testCase(MutexTests.__allTests),
        testCase(WaitTimeTests.__allTests),
    ]
}
#endif
