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
        
        func _parseObject() -> (value: Dictionary<String,JsonValue>?, error: Error?) {
            
            var result = Dictionary<String,JsonValue>()
            
            // StartObject has already been parsed
            
            while(true) {
                var key = _tokenizer.getToken()
                
                if key.error {
                    return (nil, key.error)
                }
                
                if key.token.isOp(Operator.EndObject) {
                    break   // empty object
                }
                
                var keyValue = key.token.string
                
                if keyValue == nil {
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: "key"))
                }
                
                var assign = _tokenizer.getToken()
                
                if assign.error {
                    return (nil, assign.error)
                }
                
                if !assign.token.isOp(Operator.Assign) {
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: ":"))
                }
                
                var value = _parseValue()
                
                if value.error {
                    return (nil, value.error)
                }

                result[keyValue!] = value.value!
                
                var separator = _tokenizer.getToken()
                
                if separator.error {
                    return (nil, separator.error)
                }
                
                if !separator.token.isOp(Operator.Seperator) {
                    
                    if separator.token.isOp(Operator.EndObject) {
                        break
                    }
                    
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: ", or }"))
                }
            }
            
            return (result, nil)
        }
        
        
        func _parseArray() -> (value: JsonValue[]?, error: Error?) {
            
            // StartArray has already been parsed
            
            var result = JsonValue[]()
            
            while(true)
            {
                var end = _tokenizer.getToken()
                
                if end.error {
                    return (nil, end.error)
                }
                
                if end.token.isOp(Operator.EndArray) {
                    break
                }
                
                _tokenizer.ungetToken(end.token)
                
                var value = _parseValue()
                
                if value.error {
                    return (nil, value.error)
                }
                
                result += value.value!
                
                var separator = _tokenizer.getToken()
                
                if separator.error {
                    return (nil, separator.error)
                }
                
                if !separator.token.isOp(Operator.Seperator) {
                    if separator.token.isOp(Operator.EndArray) {
                        break
                    }
                    
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: ", or ]"))
                }
            }
            
            return (result, nil)
        }
        
        
        func _parseValue() -> (value: JsonValue?, error: Error?) {
            
            let result = _tokenizer.getToken()
            
            if result.error {
                return (nil, result.error)
            }
            
            if result.token.isValue {
                return (result.token.value, nil)
            }
            
            if result.token.isOp(Operator.StartObject) {
                let object = _parseObject()
                
                if object.error {
                    return (nil, object.error)
                }
                
                return (JsonValue.ObjectValue(object.value!), nil)
            }
            
            if result.token.isOp(Operator.StartArray) {
                let array = _parseArray()
                
                if array.error {
                    return (nil, array.error)
                }
                
                return (JsonValue.ArrayValue(array.value!), nil)
            }
            
            return (nil, Error(code: Error.Code.UnexpectedToken, location: _tokenizer.location, token: "\(result.token)"))
        }
        
        
        class func parseText(text: String) -> (value: JsonValue!, error: Error?) {
            
            var parser = Parser()
            
            parser._tokenizer = Tokenizer(text: text)

            let (value, error) = parser._parseValue()
            
            if error {
                return (nil, error)
            }
            
            // Check we are at then end of our string...
            
            let (eofToken, error2) = parser._tokenizer.getToken()
            
            if error2 {
                return (nil, error2)
            }
            
            if !eofToken.isEOF {
                return (nil, Error(code: Error.Code.UnexpectedToken, location: parser._tokenizer.location, token: "\(eofToken)"))
            }
            
            // all looks good, return the value!
            
            return (value, nil)
        }
    }
}
