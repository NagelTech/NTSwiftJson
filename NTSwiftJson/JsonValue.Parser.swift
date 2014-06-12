//
//  JsonValue.Parser.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/11/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


extension JsonValue {
    
    class Parser
    {
        var _tokenizer: Tokenizer!
        var _error: NSError? = nil
        
        
        func _parseObject() -> Dictionary<String,JsonValue>? {
            
            var result = Dictionary<String,JsonValue>()
            
            // StartObject has already been parsed
            
            while(true) {
                var keyToken = _tokenizer.getToken()
                
                if keyToken.isOp(Operator.EndObject) {
                    break   // empty object
                }
                
                var key = keyToken.asText
                
                if key == nil {
                    println("Error: expected key")
                    return nil  // error: expected key
                }
                
                if !_tokenizer.getToken().isOp(Operator.Assign) {
                    println("Error: expected :")
                    return nil // error: expected ":"
                }
                
                var value = _parseValue()
                
                if value == nil {
                    println("Error: expected value")
                    return nil  // error: expected value
                }
                
                result[key!] = value!
                
                var seperator = _tokenizer.getToken()
                
                if !seperator.isOp(Operator.Seperator) {
                    
                    if seperator.isOp(Operator.EndObject) {
                        break
                    }
                    
                    println("Error: expected , or }")
                    return nil // error: expected "," or "}"
                }
            }
            
            return result
        }
        
        
        func _parseArray() -> JsonValue[]? {
            var result = JsonValue[]()
            
            while(true)
            {
                var endArray = _tokenizer.getToken()
                
                if endArray.isOp(Operator.EndArray) {
                    break
                }
                
                _tokenizer.ungetToken(endArray)
                
                var value = _parseValue()
                
                if !value {
                    println("Error: expected value")
                    return nil // error: expected value
                }
                
                result += value!
                
                var seperator = _tokenizer.getToken()
                
                if !seperator.isOp(Operator.Seperator) {
                    if seperator.isOp(Operator.EndArray) {
                        break
                    }
                    
                    println("Error: expected , or ]")
                    return nil // error: expected "," or "]"
                }
            }
            
            return result
        }
        
        
        func _parseValue() -> JsonValue? {
            
            let token = _tokenizer.getToken()
            
            if token.isValue {
                return token.asValue
            }
            
            if token.isOp(Operator.StartObject) {
                let object = _parseObject()
                
                return (object) ? JsonValue.ObjectValue(object!) : nil
            }
            
            if token.isOp(Operator.StartArray) {
                let array = _parseArray()
                
                return (array) ? JsonValue.ArrayValue(array!) : nil
            }
            
            println("Error unexpected token: (\token)")
            
            return nil  // error
        }
        
        
        class func parseText(text: String) -> JsonValue? {
            
            var parser = Parser()
            
            parser._tokenizer = Tokenizer(text: text)
            
            return parser._parseValue()
        }
    }
}
