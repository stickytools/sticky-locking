///
///  Lock+RequestTests.swift
//  StickyLockingTests
//
///  Created by Tony Stone on 11/24/17.
///
import XCTest
import Dispatch

@testable import StickyLocking

class LockRequestTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(Lock.Request(.NL))
    }

    func testInitWithDefaultLockerValue() {
        XCTAssertEqual(Lock.Request(.NL).locker, Lock.Locker())
    }

    func testInitWithLocker() {
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()

        /// Force new thread to get another locker instance.
        var locker = Lock.Locker()
        queue.async(group: group) {
            locker = Lock.Locker()
        }
        group.wait()

        XCTAssertEqual(Lock.Request(.NL, locker: locker).locker, locker)
    }

    func testStatusDefaultValue() {
        XCTAssertEqual(Lock.Request(.NL).status, .requested)
    }

    func testCountDefaultValue() {
        XCTAssertEqual(Lock.Request(.NL).count, 1)
    }

    func testMode() {
        XCTAssertEqual(Lock.Request(.NL).mode, .NL)
    }

    func testCountIncrementAssign() {
        let input = Lock.Request(.NL)

        input.count += 1
        XCTAssertEqual(input.count, 2)
    }

    func testWaitSignal() {

        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()

        let mutex = Mutex()
        let request = Lock.Request(.S)

        queue.async(group: group) {
            mutex.lock()
            XCTAssertEqual(request.wait(on: mutex), true)
            mutex.unlock()
        }
        /// This call confirms that the block is waiting
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .timedOut)

        /// Now singal the request wait to allow it to continue
        mutex.lock()
        request.signal()
        mutex.unlock()

        /// We should get a success here since the block should leave the dispatch group immediately.
        XCTAssertEqual(group.wait(timeout: .now() + 0.1), .success)
    }

}
