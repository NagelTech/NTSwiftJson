//
//  JsonValue.Error.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/12/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


extension JsonValue {
    
    class Error : NSError {
        let Domain = "JsonValueError"
        
        
        enum Code: Int {
            case UnterminatedString = 1
            case UnexpectedToken = 2
            case Expected = 3
        }
        
        
        var row: Int { return self.userInfo["row"] as Int }
        
        
        var column: Int { return self.userInfo["column"] as Int }
        
        
        var token: String! { return self.userInfo["token"] as? String }

        
        init(code: Code, location: Location, token: String? = nil) {
            
            var userInfo : NSMutableDictionary = ["row": location.row+1, "column": location.column+1]
            
            if token != nil {
                userInfo["token"] = token!
            }
            
            super.init(domain: Domain, code: code.toRaw(), userInfo: userInfo)
        }
        
        
        override var localizedDescription: String! {
            switch Code.fromRaw(super.code)! {
                case .UnterminatedString: return "Unterminated string starting at (\(row), \(column))"
                case .UnexpectedToken: return "Unexpected token \"\(token)\" at (\(row), \(column))"
                case .Expected: return "Expected \(token) at  (\(row), \(column))"
            }
        }
        
    }
    
}
