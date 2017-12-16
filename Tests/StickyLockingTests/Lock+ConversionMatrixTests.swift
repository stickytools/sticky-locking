///
///  Lock+GroupModeMatrixTests.swift
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
///  Created by Tony Stone on 12/12/17.
///
import XCTest

@testable import StickyLocking

class LockGroupModeMatrixTests: XCTestCase {

    enum TestMode: Lock.Mode {
        case S, X
    }

    let matrix = Lock.GroupModeMatrix<TestMode>(arrayLiteral: [[.S, .X],
                                                                [.X, .X]])

    func testInitAndCompatible() {

        /// S
        XCTAssertEqual(matrix.convert(requested: .S, current: .S), .S)
        XCTAssertEqual(matrix.convert(requested: .S, current: .X), .X)

        /// X
        XCTAssertEqual(matrix.convert(requested: .X, current: .S), .X)
        XCTAssertEqual(matrix.convert(requested: .X, current: .X), .X)
    }

    func testDescription() {
        XCTAssertEqual(matrix.description, """
                                           [[S,     X],
                                            [X,     X]]
                                           """)
    }

    func testDebugDescription() {
        XCTAssertEqual(matrix.debugDescription, """
                                           [[S,     X],
                                            [X,     X]]
                                           """)
    }
}

