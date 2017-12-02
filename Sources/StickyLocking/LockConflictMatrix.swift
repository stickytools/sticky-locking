///
///  LockConflictMatrix.swift
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
///  Created by Tony Stone on 11/30/17.
///
import Swift

///
/// A square matrix indexed by LockMode's holding a `Bool` indicating conflict or no conflict of the intersection fo the modes.
///
public class LockConflictMatrix: LockModeMatrix<LockMode, Bool> {

    public static let `default` = LockConflictMatrix(arrayLiteral:
        [
            /* Requested       IS,    IX,    S,    SIX,    U,     X   */
            /* IS        */  [true,  true,  true,  true,  true,  false],
            /* IX        */  [true,  true,  false, false, false, false],
            /* S         */  [true,  false, true,  false, true,  false],
            /* SIX       */  [true,  false, false, false, false, false],
            /* U         */  [true,  false, true,  false, false, false],
            /* X         */  [false, false, false, false, false, false]
        ]
    )

    ///
    /// Returns whether the `requested` mode is compatible with the `current` mode.
    ///
    /// - Parameters:
    ///     - requested: the requested mode in the matrix expressed as a LockMode value.
    ///     - current: the current mode in the matrix expressed as a LockMode value.
    ///
    @inline(__always)
    public func compatible(requested: LockMode, current: LockMode?) -> Bool {
        if let current = current {
            return self[requested, current]
        }
        return true
    }
}
