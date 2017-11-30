///
///  LockMatrix.swift
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
import Swift

///
/// A constrained multidimensional array representing combinations of locks and the access allowed for each pair.
///
public struct LockMatrix {

    ///
    /// Internal storage array of arrays
    ///
    private var matrix: [[Bool]]
}

///
/// LockMatrix Construction
///
extension LockMatrix {

    public static let defaultMatrix = LockMatrix(arrayLiteral:
        [
            /* Requested      NL,    IS,    IX,    S,    SIX,    U,     X   */
            /* NL        */  [true, true,  true,  true,  true,  true,  true],
            /* IS        */  [true, true,  true,  true,  true,  true,  false],
            /* IX        */  [true, true,  true,  false, false, false, false],
            /* S         */  [true, true,  false, true,  false, true,  false],
            /* SIX       */  [true, true,  false, false, false, false, false],
            /* U         */  [true, true,  false, true,  false, false, false],
            /* X         */  [true, false, false, false, false, false, false]
        ]
    )

    ///
    /// Initialize an LockMatrix with an Array of Arrays of
    /// of Access values.
    ///
    /// - Parameter: arrayLiteral: [[Bool]] Array of `Bool` arrays.
    ///
    /// - Requires: 7 x 7 matrix passed.
    ///
    public init(arrayLiteral elements: [[Bool]]) {
        assert( elements.count == 7 &&
            elements[LockMode.NL.rawValue].count  == 7 &&
            elements[LockMode.IS.rawValue].count  == 7 &&
            elements[LockMode.IX.rawValue].count  == 7 &&
            elements[LockMode.S.rawValue].count   == 7 &&
            elements[LockMode.SIX.rawValue].count == 7 &&
            elements[LockMode.U.rawValue].count   == 7 &&
            elements[LockMode.X.rawValue].count   == 7
        )
        self.matrix = elements
    }
}

///
/// Sequence support for LockMatrix
///
extension LockMatrix {

    ///
    /// Returns whether the `requested` mode is compatible with the `current` mode.
    ///
    /// - Parameters:
    /// - requested: the requested mode in the matrix expressed as a LockMode value.
    /// - current: the current mode in the matrix expressed as a LockMode value.
    ///
    public func compatible(requested: LockMode, current: LockMode) -> Bool {
        return matrix[requested.rawValue][current.rawValue]
    }
}

extension LockMatrix: CustomStringConvertible, CustomDebugStringConvertible {

     public var description: String {
        let modeCount = LockMode.allValues.count
        var string = "["

        for row in 0..<modeCount {
            if row > 0 { string += " " }
            string += "["

            var first = true
            var lastCount = 0
            for col in 0..<modeCount {
                if !first { string += ", " + String(repeatElement(" ", count: 5 - lastCount)) }

                let modeString = "\(self.matrix[row][col])"
                string += modeString

                first = false; lastCount = modeString.count
            }
            string += "]"
            if row < modeCount - 1 { string += ",\n" }
        }
        string += "]"
        return string
    }

    public var debugDescription: String {
        return self.description
    }
}
