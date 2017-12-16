///
///  Locker+UnrestrictedConflictMatrix.swift
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
///  Created by Tony Stone on 12/3/17.
///
import XCTest
import Dispatch

import StickyLocking

///
/// `Locker` Tests
///
class LockerUnrestrictedConflictMatrixTests: XCTestCase {

    let locker = Locker(conflictMatrix: Lock.ConflictMatrix<LockMode>(arrayLiteral:
        [
            /* Requested       IS,    IX,    S,    SIX,    U,     X   */
            /* IS        */  [true,  true,  true,  true,  true,  true],
            /* IX        */  [true,  true,  true,  true,  true,  true],
            /* S         */  [true,  true,  true,  true,  true,  true],
            /* SIX       */  [true,  true,  true,  true,  true,  true],
            /* U         */  [true,  true,  true,  true,  true,  true],
            /* X         */  [true,  true,  true,  true,  true,  true]
        ]
    ), groupModeMatrix: LockMode.groupModeMatrix)

    func testLockWhenExistingLock() throws {
        let input = Lock.ResourceID(identifier: "database")

        let group = DispatchGroup()

        XCTAssertEqual(self.locker.lock(input, mode: .S), .granted)

        DispatchQueue.global().async(group: group) {

            /// With this matrix S and X are compatible so these should succeed
            XCTAssertEqual(self.locker.lock(input, mode: .X, timeout: .now() + 0.1), .granted)
            XCTAssertEqual(self.locker.unlock(input), true)
        }
        group.wait()

        /// Cleanup
        XCTAssertEqual(self.locker.unlock(input), true)
    }
}
