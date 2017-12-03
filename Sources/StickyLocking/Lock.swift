///
///  Lock.swift
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
///  Created by Tony Stone on 11/20/17.
///
import Foundation

///
/// Lock namespace
///
public enum Lock {

    ///
    /// Resource ID to lock.
    ///
    public struct ResourceID: Hashable {

        public init(identifier: String) {
            self.identifier = identifier
            self.hashValue = self.identifier.hashValue
        }

        public static func ==(lhs: ResourceID, rhs: ResourceID) -> Bool {
            return lhs.identifier == rhs.identifier
        }

        public var hashValue: Int
        private let identifier: String
    }

    ///
    /// Type which defines the modes available to lock a resource in.
    ///
    public struct Mode: ExpressibleByIntegerLiteral, Equatable {

        public init(integerLiteral value: Int) {
            self.value = value
        }
        public static func == (lhs: Mode, rhs: Mode) -> Bool {
            return lhs.value == rhs.value
        }
        public var value: Int
    }

    ///
    /// A square matrix indexed by LockMode's holding a `Bool` indicating conflict or no conflict of the intersection fo the modes.
    ///
    public class ConflictMatrix<T: RawRepresentable> where T.RawValue == Lock.Mode {

        public init(arrayLiteral elements: [[Bool]]) {
            assert( elements.reduce(0, {  $0 + ($1.count == elements.count ? 1 : 0)  }) == elements.count, "arrayLiteral must be equal rows and columns.")

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
}

///
/// `CustomStringConvertible` and `CustomDebugStringConvertible` conformance.
///
extension Lock.ResourceID: CustomStringConvertible, CustomDebugStringConvertible  {

    public var description: String {
        return "\"\(self.identifier)\""
    }

    public var debugDescription: String {
        return "Lock.ResourceID(hashValue: \(self.hashValue), identifier: \"\(self.identifier)\")"
    }
}

///
/// Lock.Mode CustomStringConvertible and CustomDebugStringConvertible conformance.
///
extension Lock.Mode: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return "\(self.value)"
    }

    public var debugDescription: String {
        return description
    }
}

///
/// Lock.ConflictMatrix CustomStringConvertible and CustomDebugStringConvertible conformance.
///
extension Lock.ConflictMatrix: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return StickyLocking.description(matrix: self.matrix)
    }

    public var debugDescription: String {
        return self.description
    }
}

private func description<T>(matrix: [[T]]) -> String {
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
