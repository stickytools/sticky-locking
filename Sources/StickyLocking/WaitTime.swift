///
///  WaitTime.swift
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
///  Created by Tony Stone on 11/25/17.
///
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD) || os(PS4) || os(Android)  /* Swift 5 support: || os(Cygwin) || os(Haiku) */
    import Glibc
#endif

///
/// Time struct representing a point in time to stop waiting.
///
public struct WaitTime: Equatable {

    ///
    /// Returns the current time.
    ///
    public static func now() -> WaitTime {
        var timeVal = timeval()
        gettimeofday(&timeVal, nil)

        return WaitTime(rawValue: timespec(tv_sec: timeVal.tv_sec, tv_nsec: Int(timeVal.tv_usec * 1000)))
    }

    ///
    /// Maximum time wait can wait.
    ///
    public static let distantFuture = WaitTime(rawValue: timespec(tv_sec: time_t.max, tv_nsec: 0))

    ///
    /// Add a time interval in seconds to `time`.
    ///
    public static func + (time: WaitTime, seconds: Double) -> WaitTime {
        var result = time.timeSpec   /// Copy timespec

        result.tv_sec  += Int(seconds)
        result.tv_nsec += Int(seconds * Double(nanoSecondsPerSecond)) % nanoSecondsPerSecond

        if result.tv_nsec >= nanoSecondsPerSecond {
            result.tv_sec += 1
            result.tv_nsec -= nanoSecondsPerSecond
        } else if result.tv_nsec < 0 {
            result.tv_sec -= 1
            result.tv_nsec += nanoSecondsPerSecond
        }
        return WaitTime(rawValue: result)
    }

    ///
    /// `WaitTime` == `WaitTime`
    ///
    public static func == (lhs: WaitTime, rhs: WaitTime) -> Bool {
        return lhs.timeSpec.tv_sec  == rhs.timeSpec.tv_sec &&
               lhs.timeSpec.tv_nsec == rhs.timeSpec.tv_nsec
    }

    // MARK: - Private methods and structures

    internal /* @testable */
    init(rawValue: timespec) {
        self.timeSpec = rawValue
    }

    internal var timeSpec: timespec

    private static let nanoSecondsPerSecond = 1000000000

}
