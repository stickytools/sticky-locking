///
///  LockModeMatrix.swift
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

public class LockModeMatrix<Index: LockModeType, Element> where Index.RawValue == Int {

    ///
    /// Initialize a LockModeMatrix with an Array of Arrays of of `Element` values indexed by `Index`.
    ///
    /// - Parameter: arrayLiteral: [[Index]] Array of `Element` arrays.
    ///
    public init(arrayLiteral elements: [[Element]]) {
        assert( elements.reduce(0, {  $0 + ($1.count == elements.count ? 1 : 0)  }) == elements.count, "arrayLiteral must be equal rows and columns.")

        self.matrix = elements
    }

    ///
    /// Internal storage array of arrays
    ///
    private let matrix: [[Element]]
}

///
/// Sequence support for LockModeMatrix
///
extension LockModeMatrix {

    ///
    /// Subscript the matrix returning a `Element` type
    ///
    /// - row: the row in the matrix expressed as an `Index` value.
    /// - col: the column in the matrix expressed as an `Index` value.
    ///
    /// Example:
    /// ```
    ///    let matrix = LockModeMatrix()
    ///
    ///    let access = matrix[.IS, .IX]
    /// ```
    public subscript (row: Index, col: Index) -> Element {
        return matrix[row.rawValue][col.rawValue]
    }
}

extension LockModeMatrix: CustomStringConvertible, CustomDebugStringConvertible {

     public var description: String {
        let count = self.matrix.count
        var string = "["

        for row in 0..<count {
            if row > 0 { string += " " }
            string += "["

            var first = true
            var lastCount = 0
            for col in 0..<count {
                if !first { string += ", " + String(repeatElement(" ", count: 5 - lastCount)) }

                let elementString = "\(self.matrix[row][col])"
                string += elementString

                first = false; lastCount = elementString.count
            }
            string += "]"
            if row < count - 1 { string += ",\n" }
        }
        string += "]"
        return string
    }

    public var debugDescription: String {
        return self.description
    }
}
