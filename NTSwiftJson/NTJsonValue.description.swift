//
//  NTJsonValue.description.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/13/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


extension JsonValue : Printable {
    static func _getStringDescription(string: String) -> String {
        var result: String = "\""
        
        for ch in string.unicodeScalars {
            switch(ch) {
            case "\"": result += "\\\""
            case "\\": result += "\\\\"
            case UnicodeScalar(0x0008): result += "\\b";
            case "\t": result += "\\t";
            case "\n": result += "\\n";
            case UnicodeScalar(0x000c): result += "\\f";
            case "\r": result += "\\r";
            default:
                result += ch.isASCII() ? String(ch) : NSString(format: "\\u%04d", ch.value)
            } // switch
        } // for
        
        result += "\""
        
        return result
    }
    
    
    static func _getObjectDescription(object: Dictionary<String,JsonValue>, pretty: Bool=false, level: Int=0) -> String {
        let indention = (pretty) ? String(count: (1+level)*4, repeatedValue: UnicodeScalar(" ")) : ""
        let assign = (pretty) ? ": " : ":"
        let start = (pretty) ? "{\n" : "{"
        let end = (pretty) ? " }" : "}"
        let separator = (pretty) ? ",\n" : ","
        
        var result = "";
        
        for (key, value) in object {
            
            if !result.isEmpty {
                result += separator
            }
            
            result += indention + _getStringDescription(key) + assign + value._getDescription(pretty: pretty, level: level+1)
        }
        
        return (result.isEmpty) ? "{}" : start + result + end
    }
    
    
    static func _getArrayDescription(array: JsonValue[], pretty: Bool=false, level: Int=0) -> String {
        let indention = (pretty) ? String(count: (1+level)*4, repeatedValue: UnicodeScalar(" ")) : ""
        let start = (pretty) ? "[\n" : "["
        let end = (pretty) ? " ]" : "]"
        let separator = (pretty) ? ",\n" : ","
        
        var result = "";
        
        for value in array {
            
            if !result.isEmpty {
                result += separator
            }
            
            result += indention + value._getDescription(pretty: pretty, level: level+1)
        }
        
        return (result.isEmpty) ? "[]" : start + result + end
    }
    
    
    func _getDescription(#pretty: Bool, level: Int=0) -> String {
        switch(self) {
        case .StringValue(let value): return JsonValue._getStringDescription(value)
        case .IntValue(let value): return "\(value)"
        case .DoubleValue(let value): return "\(value)"
        case .BoolValue(let value): return "\(value)"
        case .Null: return "null"
        case .ObjectValue(let object): return JsonValue._getObjectDescription(object, pretty: pretty, level: level)
        case .ArrayValue(let array): return JsonValue._getArrayDescription(array, pretty: pretty, level: level)
        }
    }
    
    
    var description : String { return _getDescription(pretty: false) }
    
    
    var prettyDescription : String { return _getDescription(pretty: true) }

}