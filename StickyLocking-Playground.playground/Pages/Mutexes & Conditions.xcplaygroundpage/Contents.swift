//: Playground - noun: a place where people can play

import StickyLocking

class MyClass {
    let mutex = Mutex(.normal)

    ///
    /// Method which can be called on multiple threads
    ///
    func doSomthing() {

        self.mutex.lock()
        defer {
            self.mutex.unlock()
        }

        /// Critical code section
    }
}

let myClass = MyClass()

myClass.doSomthing()

