///
///  Lock+CompatibilityMatrixTests.swift
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

@testable import StickyLocking

class Lock_CompatibilityMatrixTests: XCTestCase {

    enum TestMode: LockMode {
        case S, X
    }

    let matrix: CompatibilityMatrix<TestMode> = [[true,  false],
                                            [false, false]]

    func testInitAndCompatible() {

        /// S
        XCTAssertEqual(matrix.compatible(requested: .S, current: .S), true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .X), false)

        /// X
        XCTAssertEqual(matrix.compatible(requested: .X, current: .S), false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .X), false)
    }

    func testDescription() {
        XCTAssertEqual(matrix.description, """
                                           [[true,  false],
                                            [false, false]]
                                           """)
    }

    func testDebugDescription() {
        XCTAssertEqual(matrix.debugDescription, """
                                           [[true,  false],
                                            [false, false]]
                                           """)
    }
}
