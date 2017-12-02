///
///  LockConflictMatrixTests.swift
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
///  Created by Tony Stone on 11/16/17.
///
import XCTest

import StickyLocking

// MARK: - All

class LockConflictMatrixTests: XCTestCase {

    func testInitArrayLiteral() {
        let matrix = LockConflictMatrix(arrayLiteral: [[true, true, true, true, true, true],
                                                       [true, true, true, true, true, true],
                                                       [true, true, true, true, true, true],
                                                       [true, true, true, true, true, true],
                                                       [true, true, true, true, true, true],
                                                       [true, true, true, true, true, true]])

        /// IS
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .X),   true)

        /// IX
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .X),   true)

        /// S
        XCTAssertEqual(matrix.compatible(requested: .S, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .X),   true)

        /// SIX
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .X),   true)

        /// U
        XCTAssertEqual(matrix.compatible(requested: .U, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .X),   true)

        /// X
        XCTAssertEqual(matrix.compatible(requested: .X, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .X),   true)
    }

    func testDefaultMatrix() {
        let matrix = LockConflictMatrix.default


        /// IS
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .SIX), true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .IS, current: .X),   false)

        /// IX
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .IX),  true)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .S),   false)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .SIX), false)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .U),   false)
        XCTAssertEqual(matrix.compatible(requested: .IX, current: .X),   false)

        /// S
        XCTAssertEqual(matrix.compatible(requested: .S, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .IX),  false)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .SIX), false)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .U),   true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .X),   false)

        /// SIX
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .IX),  false)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .S),   false)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .SIX), false)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .U),   false)
        XCTAssertEqual(matrix.compatible(requested: .SIX, current: .X),   false)

        /// U
        XCTAssertEqual(matrix.compatible(requested: .U, current: .IS),  true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .IX),  false)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .S),   true)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .SIX), false)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .U),   false)
        XCTAssertEqual(matrix.compatible(requested: .U, current: .X),   false)

        /// X
        XCTAssertEqual(matrix.compatible(requested: .X, current: .IS),  false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .IX),  false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .S),   false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .SIX), false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .U),   false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .X),   false)
    }

    func testDescription() {
        let matrix = LockConflictMatrix(arrayLiteral: [[true, true, true,  true, true, true],
                                                       [true, true, false, true, true, true],
                                                       [true, true, true,  true, true, true],
                                                       [true, true, true,  true, true, true],
                                                       [true, true, true,  true, true, true],
                                                       [true, true, true,  true, true, true]])


        XCTAssertEqual(matrix.description, """
                [[true,  true,  true,  true,  true,  true],
                 [true,  true,  false, true,  true,  true],
                 [true,  true,  true,  true,  true,  true],
                 [true,  true,  true,  true,  true,  true],
                 [true,  true,  true,  true,  true,  true],
                 [true,  true,  true,  true,  true,  true]]
                """)
    }

    func testDebugDescription() {
        let matrix = LockConflictMatrix(arrayLiteral: [[true, true, true,  true, true, true],
                                                       [true, true, false, true, true, true],
                                                       [true, true, true,  true, true, true],
                                                       [true, true, true,  true, true, true],
                                                       [true, true, true,  true, true, true],
                                                       [true, true, true,  true, true, true]])


        XCTAssertEqual(matrix.debugDescription, """
                [[true,  true,  true,  true,  true,  true],
                 [true,  true,  false, true,  true,  true],
                 [true,  true,  true,  true,  true,  true],
                 [true,  true,  true,  true,  true,  true],
                 [true,  true,  true,  true,  true,  true],
                 [true,  true,  true,  true,  true,  true]]
                """)
    }
}
