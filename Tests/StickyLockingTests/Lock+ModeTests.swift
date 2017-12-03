///
///  Lock+ModeTests.swift
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
///  Created by Tony Stone on 12/2/17.
///
import XCTest

import StickyLocking

class Lock_ModeTests: XCTestCase {

    func testInit() {
        XCTAssertEqual(Lock.Mode(integerLiteral: 10).value, 10)
    }

    func testEqualTrue() {
        XCTAssertTrue(Lock.Mode(integerLiteral: 20) == Lock.Mode(integerLiteral: 20))
    }

    func testEqualFalse() {
        XCTAssertFalse(Lock.Mode(integerLiteral: 20) == Lock.Mode(integerLiteral: 10))
    }

    func testDescription() {
        XCTAssertEqual(Lock.Mode(integerLiteral: 10).description, "10")
    }

    func testDebugDescription() {
        XCTAssertEqual(Lock.Mode(integerLiteral: 10).debugDescription, "10")
    }
}
