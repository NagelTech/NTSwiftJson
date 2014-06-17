//
//  TestBase.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/16/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import XCTest

class TestBase: XCTestCase {

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func loadTestData(name: String) -> String {
        
        var bundle = NSBundle(forClass: self.classForCoder)
        var path = bundle.pathForResource(name, ofType: "json")
        
        XCTAssert(path != nil, "unable to find resource \(name)")
        
        var data = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)

        XCTAssert(data != nil, "unable to load \(name)")

        return data!
    }


}
