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
/// Type which defines the modes available to lock a resource in.
///
/// You may define your own LockModes for any type of locking scenario you require.
///
/// Here is an example of a very simple lock Mode definition which defines a shared mode and an exclusive mode.
///
///     enum MyLockMode: LockMode {
///         case shared
///         case exclusive
///     }
///
/// - Note: If you define your own `LockMode`, you must also define a `CompatibilityMatrix` and `GroupModeMatrix` which determines the locker's behaviour for each `LockMode` defined.
///
/// - SeeAlso:
///     `CompatibilityMatrix` for information on how to define a compatibility matrix.
/// - SeeAlso:
///     `GroupModeMatrix` for information on how to define a group mode matrix.
///
public struct LockMode: ExpressibleByIntegerLiteral, Equatable {

    public init(integerLiteral value: Int) {
        self.value = value
    }
    public static func == (lhs: LockMode, rhs: LockMode) -> Bool {
        return lhs.value == rhs.value
    }
    public var value: Int
}

///
/// LockMode CustomStringConvertible and CustomDebugStringConvertible conformance.
///
extension LockMode: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return "\(self.value)"
    }

    public var debugDescription: String {
        return description
    }
}
