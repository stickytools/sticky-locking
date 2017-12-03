///
///  Lock+ConflictMatrixTests.swift
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

class Lock_ConflictMatrixTests: XCTestCase {

    func testInitAndCompatible() {

        enum TestMode: Lock.Mode {
            case S, X
        }

        let matrix = Lock.ConflictMatrix<TestMode>(arrayLiteral: [[true,  false],
                                                                  [false, false]])

        /// S
        XCTAssertEqual(matrix.compatible(requested: .S, current: .S), true)
        XCTAssertEqual(matrix.compatible(requested: .S, current: .X), false)

        /// X
        XCTAssertEqual(matrix.compatible(requested: .X, current: .S), false)
        XCTAssertEqual(matrix.compatible(requested: .X, current: .X), false)

    }
}
