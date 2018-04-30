///
///  SharedExclusiveLockMode.swift
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
///  Created by Tony Stone on 4/18/18.
///

import Swift

///
/// A Shared Exclusive lock (a.k.a. readers-writer or multi-reader) allows concurrent access for read-only
/// operations, while write operations gain exclusive access.
///
/// This allows multiple readers to gain shared access to a resource blocking all writers until no more
/// readers are reading.  Writers gain exclusive access to the resource blocking all other readers and writers
/// until the operation is complete.
///
/// The defined modes are:
///
///  * S - Shared (Read)
///  * X - Exclusive (Write)
///
/// The default `CompatibilityMatrix` is defined as:
///
/// | Requested |    S   |    X   |
/// |:---------:|:------:|:------:|
/// |  **S**    |&#x2714;|&#x2718;|
/// |  **X**    |&#x2718;|&#x2718;|
///
/// The default `GroupModeMatrix` is defined  as:
///
/// | Requested |   S    |    X   |
/// |:---------:|:------:|:------:|
/// |  **S**    |   S    |    X   |
/// |  **X**    |   X    |    X   |
///
///
public enum SharedExclusiveLockMode: LockMode {

    /// Shared Lock Mode.
    case S

    /// Exclusive Lock Mode.
    case X

    ///
    /// The default compatibility matrix defined for this `LockMode`.
    ///
    public static let compatibilityMatrix: CompatibilityMatrix<SharedExclusiveLockMode>
            = [
                /* Requested     Shared, Exclusive  */
                /* Shared    */  [true,    false],
                /* Exclusive */  [false,   false],
              ]

    ///
    /// The default group mode matrix defined for this `LockMode`.
    ///
    public static let groupModeMatrix: GroupModeMatrix<SharedExclusiveLockMode>
            = [
                /* Requested     Shared, Exclusive  */
                /* Shared    */  [S,     X],
                /* Exclusive */  [X,     X],
              ]
}
