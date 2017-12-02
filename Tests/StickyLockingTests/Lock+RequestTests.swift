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
        XCTAssertNotNil(Lock.Request(.S))
    }

    func testInitWithDefaultLockerValue() {
        XCTAssertEqual(Lock.Request(.S).requester, Lock.Requester())
    }

    func testInitWithLocker() {
        let group = DispatchGroup()

        /// Force new thread to get another requester instance.
        var locker = Lock.Requester()
        DispatchQueue.global().async(group: group) {
            locker = Lock.Requester()
        }
        group.wait()

        XCTAssertEqual(Lock.Request(.S, requester: locker).requester, locker)
    }

    func testStatusDefaultValue() {
        XCTAssertEqual(Lock.Request(.S).status, .requested)
    }

    func testCountDefaultValue() {
        XCTAssertEqual(Lock.Request(.S).count, 1)
    }

    func testMode() {
        XCTAssertEqual(Lock.Request(.S).mode, .S)
    }

    func testCountIncrementAssign() {
        let input = Lock.Request(.S)

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
