///
///  WaitTimeTests.swift
///
///  Copyright 2017 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 11/25/17.
///
import XCTest

@testable import StickyLocking

private let nanoSecondsPerSecond = 1000000000

class WaitTimeTests: XCTestCase {

    func testNow() {
        /// NOTE: These tests are very dependent on timing,  if test run runs slowly, this test could fail.

        var timeVal = timeval()
        gettimeofday(&timeVal, nil)

        let input = WaitTime.now()
        let expected = timespec(tv_sec: timeVal.tv_sec, tv_nsec: Int(timeVal.tv_usec * 1000))  /// We expect this value to be withing `accuracy` of the `WaitTime.now()`

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(Double(input.timeSpec.tv_nsec / 1000), Double(expected.tv_nsec / 1000), accuracy: 50.0)
    }

    func testAdd1Second() {

        var input = WaitTime(rawValue: timespec(tv_sec: 0, tv_nsec: 0))  /// Start off with zero seconds.
        let expected = timespec(tv_sec: 1, tv_nsec: 0)

        input = input + 1.0 /// Add one second.

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(input.timeSpec.tv_nsec, expected.tv_nsec)
    }

    func testAdd1NanoSecondRollingTo1Second() {

        var input = WaitTime(rawValue: timespec(tv_sec: 0, tv_nsec: nanoSecondsPerSecond - 1))  /// Start off 1 nano second less than a second.
        let expected = timespec(tv_sec: 1, tv_nsec: 0)

        input = input + 0.000000001 /// Add one nano second.

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(input.timeSpec.tv_nsec, expected.tv_nsec)
    }

    func testAdd1Second1NanoSecondRollingTo2Seconds() {

        var input = WaitTime(rawValue: timespec(tv_sec: 0, tv_nsec: nanoSecondsPerSecond - 1))  /// Start off 1 nano second less than a second.
        let expected = timespec(tv_sec: 2, tv_nsec: 0)

        input = input + 1.000000001 /// Add one nano second.

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(input.timeSpec.tv_nsec, expected.tv_nsec)
    }

    func testAddNegative1NanoSecondRollingTo0NanoSeconds() {

        var input = WaitTime(rawValue: timespec(tv_sec: 1, tv_nsec: 0))  /// Start off 1 nano second less than a second.
        let expected = timespec(tv_sec: 0, tv_nsec: 999999999)

        input = input + -0.000000001 /// Add one nano second.

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(input.timeSpec.tv_nsec, expected.tv_nsec)
    }

    func testAddNegative1Second1NanoSecondRollingTo2Seconds() {

        var input = WaitTime(rawValue: timespec(tv_sec: 1, tv_nsec: 1))  /// Start off 1 nano second less than a second.
        let expected = timespec(tv_sec: 0, tv_nsec: 0)

        input = input + -1.000000001 /// Add one nano second.

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(input.timeSpec.tv_nsec, expected.tv_nsec)
    }

    func testEqualTrue() {
        let input = WaitTime.now()

        XCTAssertEqual(input, input)
    }

    func testEqualFalse() {
        let input = WaitTime.now()

        usleep(100) /// Introduce a wait so we are sure to get a different time to compare to

        XCTAssertNotEqual(input, WaitTime.now())
    }

}
