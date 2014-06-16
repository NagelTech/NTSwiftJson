//
//  JsonValue.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/10/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


enum JsonValue {
    
    case StringValue(String)
    case IntValue(Int64)
    case DoubleValue(Double)
    case BoolValue(Bool)
    case ObjectValue(Dictionary<String,JsonValue>)
    case ArrayValue(JsonValue[])
    case Null
    
    
    var string: String! {
        switch(self) {
            case .StringValue(let value): return value
            case .IntValue(let value): return "\(value)"
            case .DoubleValue(let value): return "\(value)"
            case .BoolValue(let value): return "\(value)"
            default: return nil
        }
    }
    
    
    var int: Int! {
        func convertToInt(value: Int64!) -> Int! {
            return (value != nil && value >= Int64(Int.min) && value <= Int64(Int.max)) ? Int(value) : nil
            }
            
        switch(self) {
            case .StringValue(let value): return convertToInt(JsonValue.stringToInt64(value))
            case .IntValue(let value): return convertToInt(value)
            case .DoubleValue(let value): return (value >= Double(Int.min) && value <= Double(Int.max)) ? Int(value) : nil
            case .BoolValue(let value): return (value) ? 1 : 0
            default: return nil
        }
    }
    
    
    var double: Double! {
    
        switch(self) {
            case .StringValue(let value): return JsonValue.stringToDouble(value)
            case .IntValue(let value): return Double(value)
            case .DoubleValue(let value): return value
            default: return nil
        }
    }
    
    
    var bool: Bool! {
        switch(self) {
            case .StringValue(let value):
                switch(value) {
                    case "true", "1": return true
                    case "false", "0": return false
                    default: return nil
                }
            case .IntValue(let value): return (value == 0) ? false : true
            case .BoolValue(let value): return value
            default: return nil
        }
            
    }
    
    
    var object: Dictionary<String, JsonValue>! {
        switch(self) {
            case .ObjectValue(let value): return value
            default: return nil
        }
    }

    
    var array: JsonValue[]! {
        switch(self) {
            case .ArrayValue(let value): return value
            default: return nil
        }
    }
    
    
    var isNull: Bool {
        switch(self) {
            case .Null: return true
            default: return false
        }
    }
    

    static func parseText(text: String) -> (JsonValue!, NSError?) {
        let (value, error) = Parser.parseText(text)
        
        return (value, error)
    }
    
    
    static func parseText2(text: String, inout error:NSError?) -> JsonValue! {
        let result = Parser.parseText(text)
        
        error = result.error
        
        return result.value
    }
    
    
    static func parseText2(text: String) -> JsonValue! {
        var error: NSError? = nil
        
        return parseText2(text, error: &error)
    }
    
    
    static func parseText3(text: String, inout error:NSErrorPointer) -> JsonValue! {
    let result = Parser.parseText(text)
    
    if error {
        error.memory = result.error
    }
        
    return result.value
    }

    
    static func stringToInt64(string: String) -> Int64!
    {
        let s = NSScanner(string: string)
        
        var result: Int64 = 0
        
        return (s.scanLongLong(&result) && s.atEnd) ? result : nil
    }
    
    
    static func stringToDouble(string: String) -> Double!
    {
        let s = NSScanner(string: string)
        
        var result: Double = 0
        
        return (s.scanDouble(&result) && s.atEnd) ? result : nil
    }
    
    
    static func hexStringToInt(hexString: String) -> UInt32!
    {
        let s = NSScanner(string: hexString)
        
        var result: CUnsignedInt = 0
        
        return (s.scanHexInt(&result) && s.atEnd) ? UInt32(result) : nil
    }

}
