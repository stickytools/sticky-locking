///
///  LockMode.swift
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
/// Lock mode requested.
///
public enum LockMode: Int {
    ///
    /// - Important: There should be no gaps in the rawValue of each of these from first to last otherwise allValues below will not function correctly.
    ///
    case NL     /// No lock
    case IS     /// Intention Shared
    case IX     /// Intention Exclusive
    case S      /// Shared
    case SIX    /// Shared Intention Exclusive
    case X      /// Exclusive

    ///
    /// Returns a list of all enum values as an Array.
    ///
    public static var allValues: [LockMode] = {
        var current = NL.rawValue   /// Must be first case statement in LockMode.
        return Array(
            AnyIterator<LockMode> {
                defer { current += 1 }
                return LockMode(rawValue: current)
            }
        )
    }()

    ///
    /// Returns the max of `LockMode`s in enum order.
    ///
    @inline(__always)
    internal static func max(_ lhs: LockMode, _ rhs: LockMode) -> LockMode {
        if lhs.rawValue > rhs.rawValue {
            return lhs
        }
        return rhs
    }
}
