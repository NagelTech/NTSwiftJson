//
//  JsonValue.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/10/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation

enum JsonValue : Printable {
    case StringValue(String)
    case IntValue(Int64)
    case DoubleValue(Double)
    case BoolValue(Bool)
    case ObjectValue(Dictionary<String,JsonValue>)
    case ArrayValue(JsonValue[])
    case Null
    
    var description : String {
        switch(self) {
            case .StringValue(let value): return "\"\(value)\"" // we should escape "
            case .IntValue(let value): return "\(value)"
            case .DoubleValue(let value): return "\(value)"
            case .BoolValue(let value): return "\(value)"
            case .Null: return "null"
            
            case .ObjectValue(let object):
                return object.description
            
            case .ArrayValue(let array):
                return array.description
        }
    }
    
    static func parseText(text: String) -> JsonValue? {
        return Parser.parseText(text)
    }
}
