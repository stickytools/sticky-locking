///
///  CompatibilityMatrix.swift
///
///  Copyright (c) 2018 Tony Stone
///
///   Licensed under the Apache License, Version 2.0 (the "License");
///   you may not use this file except in compliance with the License.
///   You may obtain a copy of the License at
///
///   http://www.apache.org/licenses/LICENSE-2.0
///
///   Unless required by applicable law or agreed to in writing, software
///   distributed under the License is distributed on an "AS IS" BASIS,
///   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///   See the License for the specific language governing permissions and
///   limitations under the License.
///
///  Created by Tony Stone on 4/17/18.
///
import Swift

///
/// A square matrix indexed by LockMode's holding a `Bool` indicating whether 2 modes are compatible with each
/// other, if they are, multiple locks of the compatible types can be granted together.
///
/// - Example:
///     Here is an example of simple lock Mode definition with a `CompatibilityMatrix` defined for it.
///     ```
///     enum MyLockMode: LockMode {
///         case shared
///         case exclusive
///     }
///
///     let compatibilityMatrix: CompatibilityMatrix<MyLockMode> =
///             [
///                 /* Requested     shared, exclusive  */
///                 /* shared    */  [true,    false],
///                 /* exclusive */  [false,   false],
///             ]
///     ```
/// - SeeAlso:
///     `LockMode` for information on how to define a lock mode.
/// - SeeAlso:
///     `SharedExclusiveLockMode` for a built-in simple version of the Compatibility Matrix.
/// - SeeAlso:
///     `ExtendedLockMode` for a built-in an extended version of the Compatibility Matrix.
///
public class CompatibilityMatrix<T: RawRepresentable>: ExpressibleByArrayLiteral where T.RawValue == LockMode {

    public required init(arrayLiteral elements: [Bool]...) {
        assert( MatrixValidator<T>.isValid(elements), "Array must be equal rows and columns (square) and match the number of enum case values in your LockMode enum.")

        self.matrix = elements
    }

    ///
    /// Returns whether the `requested` mode is compatible with the `current` mode.
    ///
    /// - Parameters:
    ///     - requested: the requested mode in the matrix expressed as a LockMode value.
    ///     - current: the current mode in the matrix expressed as a LockMode value.
    ///
    @inline(__always)
    internal func compatible(requested: T, current: T?) -> Bool {
        if let current = current {
            return matrix[requested.rawValue.value][current.rawValue.value]
        }
        return true
    }

    private let matrix: [[Bool]]
}

///
/// CompatibilityMatrix CustomStringConvertible and CustomDebugStringConvertible conformance.
///
extension CompatibilityMatrix: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return StickyLocking.description(matrix: self.matrix)
    }

    public var debugDescription: String {
        return self.description
    }
}
