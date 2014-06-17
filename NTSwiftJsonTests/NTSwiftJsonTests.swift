//
//  NTSwiftJsonTests.swift
//  NTSwiftJsonTests
//
//  Created by Ethan Nagel on 6/10/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import XCTest

import NTSwiftJson


class NTSwiftJsonTests: TestBase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func validateTest1(json: JsonValue)
    {
        // validate some values...
        
        let anInt = json["AnInt"]?.int
        
        XCTAssertNotNil(anInt != nil)
        XCTAssert(anInt == 42)
        let someText = json["SomeText"]?.string
        
        XCTAssert(someText != nil)
        XCTAssert(someText == "This is some \"text\"")
        
        let getReal = json["get_real"].double
        
        // XCTAssertNotNil(getReal) crashes compiler
        XCTAssert(getReal != nil)
        XCTAssert(getReal == 12345.6)
        
        XCTAssert(json["nelly"].isNull)
        
        let array = json["array"]
        XCTAssert(array != nil)
        XCTAssert(array.array.count == 5)
        XCTAssert(array[4].int == 5) // last item should be 5
        
        let nested = json["nested"]?["eggs"]?.int
        
        XCTAssert(nested != nil)
        XCTAssert(nested == 12)
        
        let escapeTest = json["escapeTest"]?.string
        XCTAssert(escapeTest != nil)
        XCTAssert(escapeTest?.hasSuffix("\u220F"))
    }
    
    
    func testJson() {
        
        var text = loadTestData("test1")
        
        var (json, error) = JsonValue.parseText(text)
    
        // Validate basic parsing...
        
        XCTAssert(error == nil, "Parser Failed with error: \(error.description)")
        println("PARSED: \(json.prettyDescription)")
        
        validateTest1(json)
        
        // Test round-tripability...
        
        var text2 = json.description
        var (json2, error2) = JsonValue.parseText(text2)
        
        XCTAssert(error == nil, "Parser Failed round-trip test with error: \(error.description)")
        
        validateTest1(json2)
        
        // Now, test comparison
        
        XCTAssert(json == json2)
        XCTAssert(JsonValue.StringValue("123") == JsonValue.IntValue(123))
        XCTAssert(JsonValue.IntValue(1) == JsonValue.BoolValue(true))
        XCTAssert(JsonValue.ObjectValue(["a": JsonValue.DoubleValue(123)]) == JsonValue.ObjectValue(["a": JsonValue.StringValue("123")]))
        
        // Modify json2 and test again
        
        var obj = json2.object! // this is a copy
        obj["get_real"] = JsonValue.StringValue("Some text");
        json2 = JsonValue.ObjectValue(obj)
        
        XCTAssert(json2["get_real"].string == "Some text")
        
        XCTAssert(json != json2)
    }
    
    
}
