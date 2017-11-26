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

    func testFuncAdd1Second() {
        /// NOTE: These tests are very dependent on timing,  if test run runs slowly, this test could fail.

        var timeVal = timeval()
        gettimeofday(&timeVal, nil)

        let input = WaitTime.now() + 1.0
        let expected = timespec(tv_sec: timeVal.tv_sec + 1, tv_nsec: Int(timeVal.tv_usec * 1000))  /// We expect this value to be withing `accuracy` of the `WaitTime.now()`

        XCTAssertEqual(input.timeSpec.tv_sec,  expected.tv_sec)
        XCTAssertEqual(Double(input.timeSpec.tv_nsec / 1000), Double(expected.tv_nsec / 1000), accuracy: 50.0)
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
