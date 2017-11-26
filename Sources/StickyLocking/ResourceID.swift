///
///  ResourceID.swift
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
///  Created by Tony Stone on 11/23/17.
///
import Swift

///
/// Resource ID used to reference the lockTable.
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
/// `CustomStringConvertible` and `CustomDebugStringConvertible` conformance.
///
extension ResourceID: CustomStringConvertible, CustomDebugStringConvertible  {

    public var description: String {
        return "\"\(self.identifier)\""
    }

    public var debugDescription: String {
        return "ResourceID(hashValue: \(self.hashValue), identifier: \"\(self.identifier)\")"
    }
}
