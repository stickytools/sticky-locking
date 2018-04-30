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
        XCTAssertNotNil(Locker<ExtendedLockMode>.Request(.S))
    }

    func testInitWithDefaultLockerValue() {
        XCTAssertEqual(Locker<ExtendedLockMode>.Request(.S).requester, Locker<ExtendedLockMode>.Requester())
    }

    func testInitWithLocker() {
        let group = DispatchGroup()

        /// Force new thread to get another requester instance.
        var locker = Locker<ExtendedLockMode>.Requester()
        DispatchQueue.global().async(group: group) {
            locker = Locker.Requester()
        }
        group.wait()

        XCTAssertEqual(Locker<ExtendedLockMode>.Request(.S, requester: locker).requester, locker)
    }

    func testStatusDefaultValue() {
        XCTAssertEqual(Locker<ExtendedLockMode>.Request(.S).waitStatus, nil)
    }

    func testCountDefaultValue() {
        XCTAssertEqual(Locker<ExtendedLockMode>.Request(.S).count, 1)
    }

    func testMode() {
        XCTAssertEqual(Locker<ExtendedLockMode>.Request(.S).mode, .S)
    }

    func testCountIncrementAssign() {
        let input = Locker<ExtendedLockMode>.Request(.S)

        input.count += 1
        XCTAssertEqual(input.count, 2)
    }

    func testWaitSignal() {

        let group = DispatchGroup()

        let mutex = Mutex()
        let request = Locker<ExtendedLockMode>.Request(.S)

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
        XCTAssertNotNil(Locker<ExtendedLockMode>.Request(.S).description.range(of: "(.*, \\.S)", options: [.regularExpression]))
    }

    func testDebugDescription() {
        XCTAssertNotNil(Locker<ExtendedLockMode>.Request(.S).debugDescription.range(of: "(.*, \\.S)", options: [.regularExpression]))
    }
}
