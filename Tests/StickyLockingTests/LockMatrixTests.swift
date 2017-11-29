///
///  LockMatrixTests.swift
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

class LockMatrixTests: XCTestCase {

    func testInitArrayLiteral() {
        let matrix = LockMatrix(arrayLiteral: [[.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow]])

        for row in LockMode.allValues {
            for col in LockMode.allValues {
                XCTAssertEqual(matrix[row, col], LockMatrix.Access.allow)
            }
        }
    }

    func testDefaultMatrix() {
        let matrix = LockMatrix.defaultMatrix

        /// NL
        XCTAssertEqual(matrix[.NL, .NL],  .allow)
        XCTAssertEqual(matrix[.NL, .IS],  .allow)
        XCTAssertEqual(matrix[.NL, .IX],  .allow)
        XCTAssertEqual(matrix[.NL, .S],   .allow)
        XCTAssertEqual(matrix[.NL, .SIX], .allow)
        XCTAssertEqual(matrix[.NL, .U],   .allow)
        XCTAssertEqual(matrix[.NL, .X],   .allow)

        /// IS
        XCTAssertEqual(matrix[.IS, .NL],  .allow)
        XCTAssertEqual(matrix[.IS, .IS],  .allow)
        XCTAssertEqual(matrix[.IS, .IX],  .allow)
        XCTAssertEqual(matrix[.IS, .S],   .allow)
        XCTAssertEqual(matrix[.IS, .SIX], .allow)
        XCTAssertEqual(matrix[.IS, .U],   .allow)
        XCTAssertEqual(matrix[.IS, .X],   .deny)

        /// IX
        XCTAssertEqual(matrix[.IX, .NL],  .allow)
        XCTAssertEqual(matrix[.IX, .IS],  .allow)
        XCTAssertEqual(matrix[.IX, .IX],  .allow)
        XCTAssertEqual(matrix[.IX, .S],   .deny)
        XCTAssertEqual(matrix[.IX, .SIX], .deny)
        XCTAssertEqual(matrix[.IX, .U],   .deny)
        XCTAssertEqual(matrix[.IX, .X],   .deny)

        /// S
        XCTAssertEqual(matrix[.S, .NL],  .allow)
        XCTAssertEqual(matrix[.S, .IS],  .allow)
        XCTAssertEqual(matrix[.S, .IX],  .deny)
        XCTAssertEqual(matrix[.S, .S],   .allow)
        XCTAssertEqual(matrix[.S, .SIX], .deny)
        XCTAssertEqual(matrix[.S, .U],   .allow)
        XCTAssertEqual(matrix[.S, .X],   .deny)

        /// SIX
        XCTAssertEqual(matrix[.SIX, .NL],  .allow)
        XCTAssertEqual(matrix[.SIX, .IS],  .allow)
        XCTAssertEqual(matrix[.SIX, .IX],  .deny)
        XCTAssertEqual(matrix[.SIX, .S],   .deny)
        XCTAssertEqual(matrix[.SIX, .SIX], .deny)
        XCTAssertEqual(matrix[.SIX, .U],   .deny)
        XCTAssertEqual(matrix[.SIX, .X],   .deny)

        /// X
        XCTAssertEqual(matrix[.X, .NL],  .allow)
        XCTAssertEqual(matrix[.X, .IS],  .deny)
        XCTAssertEqual(matrix[.X, .IX],  .deny)
        XCTAssertEqual(matrix[.X, .S],   .deny)
        XCTAssertEqual(matrix[.X, .SIX], .deny)
        XCTAssertEqual(matrix[.X, .U],   .deny)
        XCTAssertEqual(matrix[.X, .X],   .deny)
    }

    func testDescription() {
        let matrix = LockMatrix(arrayLiteral: [[.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .deny,  .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow]])


        XCTAssertEqual(matrix.description, """
                [[.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .deny,  .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow]]
                """)
    }

    func testDebugDescription() {
        let matrix = LockMatrix(arrayLiteral: [[.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .deny,  .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                                               [.allow, .allow, .allow, .allow, .allow, .allow, .allow]])


        XCTAssertEqual(matrix.debugDescription, """
                [[.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .deny,  .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
                 [.allow, .allow, .allow, .allow, .allow, .allow, .allow]]
                """)
    }
}
