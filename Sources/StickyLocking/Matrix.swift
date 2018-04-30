///
///  Matrix.swift
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

internal func description<T>(matrix: [[T]]) -> String {
    let count = matrix.count
    var string = "["

    for row in 0..<count {
        if row > 0 { string += " " }
        string += "["

        var first = true
        var lastCount = 0
        for col in 0..<count {
            if !first { string += ", " + String(repeatElement(" ", count: 5 - lastCount)) }

            let elementString = "\(matrix[row][col])"
            string += elementString

            first = false; lastCount = elementString.count
        }
        string += "]"
        if row < count - 1 { string += ",\n" }
    }
    string += "]"
    return string
}


///
/// Internal structure to validate the size of LockMode enums.
///
internal struct MatrixValidator<T: RawRepresentable>: Sequence where T.RawValue == LockMode {

    static func isValid<E>(_ elements: [[E]]) -> Bool {
        var count = 0
        for _ in MatrixValidator<T>() {
            count += 1
        }
        return elements.reduce(0, {  $0 + ($1.count == count ? 1 : 0)  }) == count
    }

    func makeIterator() -> AnyIterator<T> {
        var current = 0
        return  AnyIterator<T> {
            defer { current += 1 }
            return T.init(rawValue: LockMode(integerLiteral: current))
        }
    }
}