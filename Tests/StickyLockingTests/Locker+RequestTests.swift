///
///  Locker+RequestTests.swift
//  StickyLockingTests
//
///  Created by Tony Stone on 11/24/17.
///
import XCTest
import Dispatch

@testable import StickyLocking

class LockerRequestTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(Locker<LockMode>.Request(.S))
    }

    func testInitWithDefaultLockerValue() {
        XCTAssertEqual(Locker<LockMode>.Request(.S).requester, Locker<LockMode>.Requester())
    }

    func testInitWithLocker() {
        let group = DispatchGroup()

        /// Force new thread to get another requester instance.
        var locker = Locker<LockMode>.Requester()
        DispatchQueue.global().async(group: group) {
            locker = Locker.Requester()
        }
        group.wait()

        XCTAssertEqual(Locker<LockMode>.Request(.S, requester: locker).requester, locker)
    }

    func testStatusDefaultValue() {
        XCTAssertEqual(Locker<LockMode>.Request(.S).waitStatus, nil)
    }

    func testCountDefaultValue() {
        XCTAssertEqual(Locker<LockMode>.Request(.S).count, 1)
    }

    func testMode() {
        XCTAssertEqual(Locker<LockMode>.Request(.S).mode, .S)
    }

    func testCountIncrementAssign() {
        let input = Locker<LockMode>.Request(.S)

        input.count += 1
        XCTAssertEqual(input.count, 2)
    }

    func testWaitSignal() {

        let group = DispatchGroup()

        let mutex = Mutex()
        let request = Locker<LockMode>.Request(.S)

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

    func testDescription() {
        XCTAssertNotNil(Locker<LockMode>.Request(.S).description.range(of: "(.S, count: 1, requester: .*)", options: [.regularExpression]))
    }

    func testDebugDescription() {
        XCTAssertNotNil(Locker<LockMode>.Request(.S).debugDescription.range(of: "(.S, count: 1, requester: .*)", options: [.regularExpression]))
    }
}
