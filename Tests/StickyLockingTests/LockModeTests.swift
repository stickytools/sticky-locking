///
///  LockModeTests.swift
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
///  Created by Tony Stone on 11/19/17.
///
import XCTest

@testable import StickyLocking

class LockModeTests: XCTestCase {

    func testExhaustiveCase() {
        ///
        /// Note: you should get compiler error if you add a enum case to LockMode but you don't modify the test below to account for it.  That is why we use the case statement here.
        ///
        for mode in LockMode.allValues {
            switch mode {
            case .NL:  fallthrough
            case .IS:  fallthrough
            case .IX:  fallthrough
            case .S:   fallthrough
            case .SIX: fallthrough
            case .U:   fallthrough
            case .X:   XCTAssert(true)
                /// WARNING: DO NOT ADD A DEFAULT case path here.
            }
        }
    }

    func testAllValuesContainsAllCasesAndNoMore() {

        let input = LockMode.allValues

        XCTAssertEqual(input.count, 7)  ///Make sure it only contains the number of known values.

        /// Make sure it contains all the known values
        XCTAssertTrue(input.contains(.NL))
        XCTAssertTrue(input.contains(.IS))
        XCTAssertTrue(input.contains(.IX))
        XCTAssertTrue(input.contains(.S))
        XCTAssertTrue(input.contains(.SIX))
        XCTAssertTrue(input.contains(.U))
        XCTAssertTrue(input.contains(.X))
    }

    func testMaxFirstLessThan() {
        XCTAssertEqual(LockMode.max(.NL, .S), .S)
    }

    func testMaxFirstGreaterThan() {
        XCTAssertEqual(LockMode.max(.X, .S), .X)
    }

    func testMaxFirstEqual() {
        XCTAssertEqual(LockMode.max(.S, .S), .S)
    }
}
