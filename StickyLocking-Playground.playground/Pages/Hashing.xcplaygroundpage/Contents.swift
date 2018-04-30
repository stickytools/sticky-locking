//: [Previous](@previous)

import Swift


//: Bad: Mixing combinations of types

/// All these types hash to the same value but are different types.
Int16(1).hashValue  /// Hashes to 1
Int32(1).hashValue  /// Hashes to 1
Int64(1).hashValue  /// Hashes to 1
Int(1).hashValue    /// Hashes to 1

Int(2).hashValue

Double(1).hashValue

Float(1).hashValue

//: Good: Single type for all keys

// Sticking with a single type ensures hash values will rarely colide.
"file1".hashValue
"file2".hashValue
"file1:database1".hashValue
"file1:database1:page1".hashValue

