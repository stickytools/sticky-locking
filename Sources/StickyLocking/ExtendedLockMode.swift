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
/// A predefined `LockMode` implementation that can be used for complex database type applications.  It defines
/// an extended set of lock modes including Update and Intention mode.
///
public enum ExtendedLockMode: LockMode {

    /// Intention Shared Lock Mode.
    case IS

    /// Intention Exclusive Lock Mode.
    case IX

    /// Shared Lock Mode.
    case S

    /// Shared Intention Exclusive Lock Mode.
    case SIX

    /// Update Lock Mode: Used on resources that can be updated. Prevents a common form of deadlock that occurs when multiple sessions are reading, locking, and potentially updating resources later.
    case U

    /// Exclusive Lock Mode.
    case X

    ///
    /// The default compatibility matrix defined for this `LockMode`.
    ///
    public static let compatibilityMatrix: CompatibilityMatrix<ExtendedLockMode>
        = [
            /* Requested       IS,    IX,    S,    SIX,    U,     X   */
            /* IS        */  [true,  true,  true,  true,  true,  false],
            /* IX        */  [true,  true,  false, false, false, false],
            /* S         */  [true,  false, true,  false, true,  false],
            /* SIX       */  [true,  false, false, false, false, false],
            /* U         */  [true,  false, true,  false, false, false],
            /* X         */  [false, false, false, false, false, false]
        ]

    ///
    /// The default group mode matrix defined for this `LockMode`.
    ///
    public static let groupModeMatrix: GroupModeMatrix<ExtendedLockMode>
        = [
            /* Requested       IS,   IX,   S,    SIX,  U,    X  */
            /* IS        */  [.IS,  .IX,  .S,   .SIX, .U,   .X],
            /* IX        */  [.IX,  .IX,  .SIX, .SIX, .X,   .X],
            /* S         */  [.S,   .SIX, .S,   .SIX, .U,   .X],
            /* SIX       */  [.SIX, .SIX, .SIX, .SIX, .SIX, .X],
            /* U         */  [.U,   .X,   .U,   .SIX, .U,   .X],
            /* X         */  [.X,   .X,   .X,   .X,   .X,   .X]
        ]
}
