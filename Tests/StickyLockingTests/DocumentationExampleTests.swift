///
///  DocumentationExampleTests.swift
///
///  Copyright 2019 Tony Stone
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
///  Created by Tony Stone on 2/22/19.
///
import XCTest

import StickyLocking

class DocumentationExampleTests: XCTestCase {

    /// Documentation Examples
    ///
    /// These test should represent the documentations examples exactly
    /// with no XCTAsserts added.  These tests are to make sure that the
    /// examples compile and run.
    ///

    func testSimpleLockerCreation() throws {

        // Create a locker using the built-in `SharedExclusiveLockMode`, and it's `CompatibilityMatrix` & `GroupModeMatrix`
        let _ = Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)
    }

    func testSimpleLockerCreationExplicitelySpecialized() throws {

        // Create a locker using the built-in `SharedExclusiveLockMode`, and it's `CompatibilityMatrix` & `GroupModeMatrix`
        let _ = Locker<SharedExclusiveLockMode>(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)
    }

    func testLockAndUnlockSimpleResource() throws {

        struct ProtectedArray<T: Hashable>: ExpressibleByArrayLiteral {
            private var storage: [T] = []
            private let locker = Locker(compatibilityMatrix: SharedExclusiveLockMode.compatibilityMatrix, groupModeMatrix: SharedExclusiveLockMode.groupModeMatrix)
            private let resource = "storage"

            init(arrayLiteral elements: T...) {
                self.storage = elements.map({ $0 })
            }

            subscript(index: Int) -> T {
                get {
                    locker.lock(self.resource, mode: .S)
                    defer { locker.unlock(self.resource) }

                    return storage[index]
                }
                set {
                    locker.lock(self.resource, mode: .X)
                    defer { locker.unlock(self.resource) }

                    storage[index] = newValue
                }
            }
        }

        var array: ProtectedArray<String> = ["String 1", "String 2", "String 3"]

        array[0] = "New String"

        print(array[0])
    }
}
