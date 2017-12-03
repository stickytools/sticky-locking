///
///  ResourceIDTests.swift
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
///  Created by Tony Stone on 11/24/17.
///
import XCTest

@testable import StickyLocking

class LockResourceIDTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(Lock.ResourceID(identifier: "test id"))
    }

    func testEqualTrue() {
        XCTAssertEqual(Lock.ResourceID(identifier: "test id"), Lock.ResourceID(identifier: "test id"))
    }

    func testEqualFalse() {
        XCTAssertNotEqual(Lock.ResourceID(identifier: "test id #1"), Lock.ResourceID(identifier: "test id #2"))
    }

    func testHashValue() {
        /// Not much of a test at the moment, it does however test if the same value (a) gives the same value consitently.
        XCTAssertEqual   (Lock.ResourceID(identifier: "a").hashValue, Lock.ResourceID(identifier: "a").hashValue)
        XCTAssertNotEqual(Lock.ResourceID(identifier: "a").hashValue, Lock.ResourceID(identifier: "b").hashValue)
    }

    func testDescription() {
        XCTAssertEqual(Lock.ResourceID(identifier: "test id").description, "\"test id\"")
    }

    func testDebugDescription() {
        let input = Lock.ResourceID(identifier: "test id")
        
        XCTAssertEqual(input.debugDescription, "Lock.ResourceID(hashValue: \(input.hashValue), identifier: \"test id\")")
    }
}
