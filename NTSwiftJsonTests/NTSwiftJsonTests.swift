//
//  NTSwiftJsonTests.swift
//  NTSwiftJsonTests
//
//  Created by Ethan Nagel on 6/10/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import XCTest

import NTSwiftJson


class NTSwiftJsonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        var text = " { \"AnInt\" : 42, \"SomeText\": \"This is some \\\"text\\\"\", \"get_real\": 123.456e2, \"nelly\" : null, \"nested\" : { \"eggs\": 12 }, \"array\": [1, 2, 3, 4, 5], \"emptyObject\" : {}, \"emptyArray\": [] } "
        
        var (json, error) = JsonValue.parseText(text)
        
        XCTAssert(error == nil, "Parser Failed with error: \(error.description)")
        
        println("PARSED: \(json)")
        
        println("PARSED: \(json.prettyDescription)")
        
        XCTAssert(true, "Pass")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
