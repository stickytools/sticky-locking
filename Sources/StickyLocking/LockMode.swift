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
public enum LockMode: Lock.Mode {

    case IS     /// Intention Shared
    case IX     /// Intention Exclusive
    case S      /// Shared
    case SIX    /// Shared Intention Exclusive
    case U      /// Used on resources that can be updated. Prevents a common form of deadlock that occurs when multiple sessions are reading, locking, and potentially updating resources later.
    case X      /// Exclusive

    public static let conflictMatrix = Lock.ConflictMatrix<LockMode>(arrayLiteral:
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

    public static let groupModeMatrix = Lock.GroupModeMatrix<LockMode>(arrayLiteral:
        [
            /* Requested       IS,   IX,   S,    SIX,  U,    X  */
            /* IS        */  [.IS,  .IX,  .S,   .SIX, .U,   .X],
            /* IX        */  [.IX,  .IX,  .SIX, .SIX, .X,   .X],
            /* S         */  [.S,   .SIX, .S,   .SIX, .U,   .X],
            /* SIX       */  [.SIX, .SIX, .SIX, .SIX, .SIX, .X],
            /* U         */  [.U,   .X,   .U,   .SIX, .U,   .X],
            /* X         */  [.X,   .X,   .X,   .X,   .X,   .X]
        ]
    )
}
