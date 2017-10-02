///
///  ComplexSubclassClassTests.swift
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
///  Created by Tony Stone on 10/6/17.
///
import XCTest
import TestFixtures

///
/// ComplexSubclassClass tests.
///
/// - Note It's important to test the fixture so we can be confident that
///        when we use them for testing other parts of the system, we
///        are sure they are not causing an unwanted side affect or false
///        positve/negative.
///
class ComplexSubclassClassTests: XCTestCase {

    // MARK: - Test Initialization

    func testInitWithNoArguments() {
        let input = ComplexSubclassClass()
        let expected: (subclassStringVar: String, boolVar: Bool, intVar: Int, doubleVar: Double, stringVar: String, optionalStringVar: String?, objectVar: BasicClass, objectArrayVar: [BasicClass]) = ("", false, 0, 0.00, "", nil, BasicClass(stringVar: ""), [])

        XCTAssertEqual(input.subclassStringVar, expected.subclassStringVar)
        XCTAssertEqual(input.boolVar,           expected.boolVar)
        XCTAssertEqual(input.intVar,            expected.intVar)
        XCTAssertEqual(input.doubleVar,         expected.doubleVar)
        XCTAssertEqual(input.stringVar,         expected.stringVar)
        XCTAssertEqual(input.optionalStringVar, expected.optionalStringVar)
        XCTAssertEqual(input.objectVar,         expected.objectVar)
        XCTAssertEqual(input.objectArrayVar,    expected.objectArrayVar)

    }

    func testInitWithArguments() {
        let input = ComplexSubclassClass(subclassStringVar: "Subclass Test String", boolVar: true, intVar: 10, doubleVar: 20.10, stringVar: "Test String", optionalStringVar: "Another Test String", objectVar: BasicClass(stringVar: "Test String"), objectArrayVar: [])
        let expected: (subclassStringVar: String, boolVar: Bool, intVar: Int, doubleVar: Double, stringVar: String, optionalStringVar: String?, objectVar: BasicClass, objectArrayVar: [BasicClass]) = ("Subclass Test String", true, 10, 20.10, "Test String", "Another Test String", BasicClass(stringVar: "Test String"), [])

        XCTAssertEqual(input.subclassStringVar, expected.subclassStringVar)
        XCTAssertEqual(input.boolVar,           expected.boolVar)
        XCTAssertEqual(input.intVar,            expected.intVar)
        XCTAssertEqual(input.doubleVar,         expected.doubleVar)
        XCTAssertEqual(input.stringVar,         expected.stringVar)
        XCTAssertEqual(input.optionalStringVar, expected.optionalStringVar)
        XCTAssertEqual(input.objectVar,         expected.objectVar)
        XCTAssertEqual(input.objectArrayVar,    expected.objectArrayVar)
    }

    // MARK: - Test Equal

    func testEqualWithNoArguments() {
        let input    = ComplexSubclassClass()
        let expected = ComplexSubclassClass(subclassStringVar: "", boolVar: false, intVar: 0, doubleVar: 0.00, stringVar: "", optionalStringVar: nil, objectVar: BasicClass(), objectArrayVar: [])

        XCTAssertEqual(input, expected)
    }

    func testEqualWithArguments() {
        let input    = ComplexSubclassClass(subclassStringVar: "Subclass Test String", boolVar: true, intVar: 10, doubleVar: 20.10, stringVar: "Test String", optionalStringVar: "Another Test String", objectVar: BasicClass(stringVar: "Test String"), objectArrayVar: [])
        let expected = ComplexSubclassClass(subclassStringVar: "Subclass Test String", boolVar: true, intVar: 10, doubleVar: 20.10, stringVar: "Test String", optionalStringVar: "Another Test String", objectVar: BasicClass(stringVar: "Test String"), objectArrayVar: [])

        XCTAssertEqual(input, expected)
    }

    func testEqualDifferentSubclassStringVar() {
        let input    = ComplexSubclassClass(subclassStringVar: "Test String")
        let expected = ComplexSubclassClass(subclassStringVar: "")

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentBoolVar() {
        let input    = ComplexSubclassClass(boolVar: true)
        let expected = ComplexSubclassClass(boolVar: false)

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentIntVar() {
        let input    = ComplexSubclassClass(intVar: 10)
        let expected = ComplexSubclassClass(intVar: 0)

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentDoubleVar() {
        let input    = ComplexSubclassClass(doubleVar: 20.00)
        let expected = ComplexSubclassClass(doubleVar: 0.00)

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentStringVar() {
        let input    = ComplexSubclassClass(stringVar: "Test String")
        let expected = ComplexSubclassClass(stringVar: "")

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentOptionalStringVar() {
        let input    = ComplexSubclassClass(optionalStringVar: "Test String")
        let expected = ComplexSubclassClass(optionalStringVar: "")

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentOptionalStringVarWithNil() {
        let input    = ComplexSubclassClass(optionalStringVar: "Test String")
        let expected = ComplexSubclassClass(optionalStringVar: nil)

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentObjectVar() {
        let input    = ComplexSubclassClass(objectVar: BasicClass(stringVar: "Input"))
        let expected = ComplexSubclassClass(objectVar: BasicClass(stringVar: "Expected"))

        XCTAssertNotEqual(input, expected)
    }

    func testEqualDifferentObjectArrayVar() {
        let input    = ComplexSubclassClass(objectArrayVar: [BasicClass(stringVar: "Input")])
        let expected = ComplexSubclassClass(objectArrayVar: [BasicClass(stringVar: "Expected1"), BasicClass(stringVar: "Expected2")])

        XCTAssertNotEqual(input, expected)
    }

    // MARK: - Test Encoding

    func testEncode() throws {
        let input    = ComplexSubclassClass(subclassStringVar: "Subclass Test String", boolVar: true, intVar: 10, doubleVar: 20.10, stringVar: "Test String", optionalStringVar: "Another Test String", objectVar: BasicClass(stringVar: "Test String"), objectArrayVar: [])
        let expected = "{\"optionalStringVar\":\"Another Test String\",\"intVar\":10,\"subclassStringVar\":\"Subclass Test String\",\"boolVar\":true,\"doubleVar\":20.1,\"objectArrayVar\":[],\"objectVar\":{\"stringVar\":\"Test String\",\"intVar\":0,\"boolVar\":false,\"doubleVar\":0},\"stringVar\":\"Test String\"}"

        let result = String(data: try JSONEncoder().encode(input), encoding: .utf8)

        XCTAssertEqual(result, expected)
    }

    func testDecode() throws {
        let input = "{\"optionalStringVar\":\"Another Test String\",\"intVar\":10,\"subclassStringVar\":\"Subclass Test String\",\"boolVar\":true,\"doubleVar\":20.1,\"objectArrayVar\":[],\"objectVar\":{\"stringVar\":\"Test String\",\"intVar\":0,\"boolVar\":false,\"doubleVar\":0},\"stringVar\":\"Test String\"}".data(using: .utf8)
        let expected = ComplexSubclassClass(subclassStringVar: "Subclass Test String", boolVar: true, intVar: 10, doubleVar: 20.10, stringVar: "Test String", optionalStringVar: "Another Test String", objectVar: BasicClass(stringVar: "Test String"), objectArrayVar: [])

        if let data = input {
            let result = try JSONDecoder().decode(ComplexSubclassClass.self, from: data)

            XCTAssertEqual(result, expected)
        } else {
            XCTFail()
        }
    }

    // MARK: - Test Description

    func testDescription() {
        let input = ComplexSubclassClass(subclassStringVar: "Subclass Test String", boolVar: true, intVar: 10, doubleVar: 20.10, stringVar: "Test String", optionalStringVar: "Another Test String", objectVar: BasicClass(stringVar: "Test String"), objectArrayVar: [])
        let expected = "\(String(describing: ComplexSubclassClass.self))(subclassStringVar: \"Subclass Test String\", boolVar: true, intVar: 10, doubleVar: 20.1, stringVar: \"Test String\", optionalStringVar: \"Another Test String\", objectVar: \(String(describing: BasicClass.self))(boolVar: false, intVar: 0, doubleVar: 0.0, stringVar: \"Test String\"), objectArrayVar: [])"

        XCTAssertEqual(input.description, expected)
    }
}
