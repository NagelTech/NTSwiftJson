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
        
        func _parseObject() -> (Dictionary<String,JsonValue>?, Error?) {
            
            var result = Dictionary<String,JsonValue>()
            var error: Error?
            
            // StartObject has already been parsed
            
            while(true) {
                var (keyToken, error1) = _tokenizer.getToken()
                
                if error1 {
                    return (nil, error1)
                }
                
                if keyToken.isOp(Operator.EndObject) {
                    break   // empty object
                }
                
                var key = keyToken.string
                
                if key == nil {
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: "key"))
                }
                
                var (assignToken, error2) = _tokenizer.getToken()
                
                if error2 {
                    return (nil, error2)
                }
                
                if !assignToken.isOp(Operator.Assign) {
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: ":"))
                }
                
                var (value, error3) = _parseValue()
                
                if error3 {
                    return (nil, error3)
                }

                if value == nil {
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: "value"))
                }
                
                result[key!] = value!
                
                var (seperatorToken, error4) = _tokenizer.getToken()
                
                if error4 {
                    return (nil, error4)
                }
                
                if !seperatorToken.isOp(Operator.Seperator) {
                    
                    if seperatorToken.isOp(Operator.EndObject) {
                        break
                    }
                    
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: ", or }"))
                }
            }
            
            return (result, nil)
        }
        
        
        func _parseArray() -> (JsonValue[]?, Error?) {
            var result = JsonValue[]()
            
            while(true)
            {
                var (endArray, error1) = _tokenizer.getToken()
                
                if error1 {
                    return (nil, error1)
                }
                
                if endArray.isOp(Operator.EndArray) {
                    break
                }
                
                _tokenizer.ungetToken(endArray)
                
                var (value, error2) = _parseValue()
                
                if error2 {
                    return (nil, error2)
                }
                
                result += value!
                
                var (seperator, error3) = _tokenizer.getToken()
                
                if error3 {
                    return (nil, error3)
                }
                
                if !seperator.isOp(Operator.Seperator) {
                    if seperator.isOp(Operator.EndArray) {
                        break
                    }
                    
                    return (nil, Error(code: Error.Code.Expected, location: _tokenizer.location, token: ", or ]"))
                }
            }
            
            return (result, nil)
        }
        
        
        func _parseValue() -> (JsonValue?, Error?) {
            
            let (token, error) = _tokenizer.getToken()
            
            if error {
                return (nil, error)
            }
            
            if token.isValue {
                return (token.value, nil)
            }
            
            if token.isOp(Operator.StartObject) {
                let (object, error) = _parseObject()
                
                if error {
                    return (nil, error)
                }
                
                return (JsonValue.ObjectValue(object!), nil)
            }
            
            if token.isOp(Operator.StartArray) {
                let (array, error) = _parseArray()
                
                if error {
                    return (nil, error)
                }
                
                return (JsonValue.ArrayValue(array!), nil)
            }
            
            return (nil, Error(code: Error.Code.UnexpectedToken, location: _tokenizer.location, token: "\(token)"))
        }
        
        
        class func parseText(text: String) -> (JsonValue!, Error?) {
            
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
