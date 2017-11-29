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
    /// Access specifier for lock matrix
    ///
    public enum Access { case allow, deny }

    ///
    /// Internal storage array of arrays
    ///
    private var matrix: [[Access]]
}

///
/// LockMatrix Construction
///
extension LockMatrix {

    public static let defaultMatrix = LockMatrix(arrayLiteral:
        [
            /* Requested        NL,    IS,     IX,     S,      SIX,     U,      X   */
            /* NL        */  [.allow, .allow, .allow, .allow, .allow, .allow, .allow],
            /* IS        */  [.allow, .allow, .allow, .allow, .allow, .allow, .deny],
            /* IX        */  [.allow, .allow, .allow, .deny,  .deny,  .deny,  .deny],
            /* S         */  [.allow, .allow, .deny,  .allow, .deny,  .allow, .deny],
            /* SIX       */  [.allow, .allow, .deny,  .deny,  .deny,  .deny,  .deny],
            /* U         */  [.allow, .deny,  .deny,  .deny,  .deny,  .deny,  .deny],
            /* X         */  [.allow, .deny,  .deny,  .deny,  .deny,  .deny,  .deny]
        ]
    )

    ///
    /// Initialize an LockMatrix with an Array of Arrays of
    /// of Access values.
    ///
    /// - Parameter: arrayLiteral: [[Access]] Array of `Access` arrays.
    ///
    /// - Requires: 7 x 7 matrix passed.
    ///
    public init(arrayLiteral elements: [[Access]]) {
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
    /// subscript the matrix returning a `Access` type
    ///
    /// - Parameters:
    /// - row: the row in the matrix expressed as an LockMode value.
    /// - col: the column in the matrix expressed as an LockMode value.
    ///
    /// Example:
    /// ```
    ///    let matrix = LockMatrix()
    ///
    ///    let access = matrix[.IS, .IX]
    /// ```
    ///
    public subscript (row: LockMode, col: LockMode) -> Access {
        get { return matrix[row.rawValue][col.rawValue] }
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
                if !first { string += ", " + String(repeatElement(" ", count: 6 - lastCount)) }

                let modeString = ".\(self.matrix[row][col])"
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
