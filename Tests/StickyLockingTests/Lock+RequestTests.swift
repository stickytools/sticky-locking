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
        XCTAssertEqual(Lock.Request(.NL).requester, Lock.Requester())
    }

    func testInitWithLocker() {
        let group = DispatchGroup()

        /// Force new thread to get another requester instance.
        var locker = Lock.Requester()
        DispatchQueue.global().async(group: group) {
            locker = Lock.Requester()
        }
        group.wait()

        XCTAssertEqual(Lock.Request(.NL, requester: locker).requester, locker)
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

        let group = DispatchGroup()

        let mutex = Mutex()
        let request = Lock.Request(.S)

        DispatchQueue.global().async(group: group) {
            mutex.lock()
            XCTAssertEqual(request.wait(on: mutex), .success)
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
