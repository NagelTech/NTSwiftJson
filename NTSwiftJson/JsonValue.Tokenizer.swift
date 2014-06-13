//
//  JsonValue.Tokenizer.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/11/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


extension JsonValue {
    
    
    enum Operator : String {
        case Assign = ":"
        case Seperator = ","
        case StartObject = "{"
        case EndObject = "}"
        case StartArray = "["
        case EndArray = "]"
    }
    
    
    enum Token : Printable {
        case StringValue(String)            // quoted string
        case IntValue(Int64)                // whole number
        case DoubleValue(Double)            // floating point value
        case BoolValue(Bool)                // true/false
        case Null                           // uhh yeah.
        case Op(Operator)                   // Any operator (see Operator enum)
        case EOF                            // end of string
        
        
        var description: String {
            switch(self) {
                case .StringValue(let value): return "\"\(value)\""
                case .IntValue(let value): return "\(value)"
                case .DoubleValue(let value): return "\(value)"
                case .BoolValue(let value): return "\(value)"
                case .Null: return "null"
                case .Op(let value): return value.toRaw()
                case .EOF: return "<<EOF>>"
            }
        }
        
        
        var isEOF: Bool {
            switch(self) {
                case .EOF: return true
                default: return false
            }
        }
        
        
        var isString: Bool {
            switch(self) {
                case .StringValue: return true
                default: return false
            }
        }
        
        
        var string: String? {
            switch(self) {
                case .StringValue(let value): return value
                default: return nil
            }
        }
        
        
        var isValue: Bool {
            switch(self) {
                case .StringValue, .IntValue, .DoubleValue, .BoolValue, .Null: return true
                default: return false
            }
        }
        
        
        var value: JsonValue? {
            switch(self) {
                case .StringValue(let value): return JsonValue.StringValue(value)
                case .IntValue(let value): return JsonValue.IntValue(value)
                case .DoubleValue(let value): return JsonValue.DoubleValue(value)
                case .BoolValue(let value): return JsonValue.BoolValue(value)
                case .Null: return JsonValue.Null
                default: return nil
            }
        }
        
        
        func isOp(operator: Operator) -> Bool {
            switch(self) {
                case .Op(let value): return (value == operator)
                default: return false
            }
        }
    }
    
    
    struct Location {
        var row = 0
        var column = 0
    }
    
   
    class Tokenizer {
        var _current: String.UnicodeScalarView.GeneratorType
        var _ungetcBuffer: UnicodeScalar? = nil
        var _ungetTokenBuffer: Token? = nil
        var _location: Location
        
        
        init(text:String) {
            _current = text.unicodeScalars.generate()
            _location = Location(row: 0, column: 0)
        }

        
        var location: Location { return _location }
        
        
        func _getc() -> UnicodeScalar! {
            
            if ( _ungetcBuffer )
            {
                let value = _ungetcBuffer
                _ungetcBuffer = nil
                
                return value
            }
            
            let c = _current.next()
            
            if c {
                
                if c == "\n" {
                    ++_location.row
                    _location.column = 0
                } else {
                    ++_location.column
                }
            }
            
            return c
        }
        
        
        func _ungetc(c: UnicodeScalar!)
        {
            assert(_ungetcBuffer == nil, "Parser Error - ungetc when buffer is full!")
            
            if c {
                _ungetcBuffer = c
            }
        }
        
        
        func ungetToken(token: Token) {
            assert(_ungetTokenBuffer == nil, "Parser Error - ungetToken when buffer is full!")
            
            _ungetTokenBuffer = token
        }
        
        
        func getToken() -> (token: Token!, error: Error?)
        {
            if _ungetTokenBuffer {
                let value = _ungetTokenBuffer
                _ungetTokenBuffer = nil
                
                return (value, nil)
            }
            
            // First, skip any spaces...
            
            while let c = _getc() {
                if !c.isSpace() {
                    _ungetc(c)
                    break
                }
            }
            
            var loc = _location
            
            var c = _getc()
            
            if !c {
                return (Token.EOF, nil)  // no remaining tokens
            }
            
            // Parse operators (all are single char)...
            
            if let operator = Operator.fromRaw(String(c)) {
                return (Token.Op(operator), nil)
            }
            
            // Parse Numbers...
            
            if c.isDigit() || c == "+" || c == "-" {
                
                var s = String(c)
                var isDoubleValue = false
                
                // parse initial digits...
                
                c = _getc()
                
                while c != nil && c.isDigit() {
                    s += String(c)
                    c = _getc()
                }
                
                // parse fraction...
                
                if c != nil && c == "." {
                    isDoubleValue = true
                    s += "."
                    
                    c = _getc()
                    while c != nil && c.isDigit() {
                        s += String(c)
                        c = _getc()
                    }
                }
                
                // parse exponent...
                
                if c != nil && (c == "e" || c == "E") {
                    isDoubleValue = true
                    
                    s += String(c)
                    
                    c = _getc()
                    
                    if c != nil && (c == "+" || c == "-") {
                        s += String(c)
                        c = _getc()
                    }
                    
                    while c != nil && c.isDigit() {
                        s += String(c)
                        c = _getc()
                    }
                }
                
                _ungetc(c)
                
                if isDoubleValue {
                    return (Token.DoubleValue( JsonValue.stringToDouble(s)! ), nil)
                } else {
                    return (Token.IntValue( JsonValue.stringToInt64(s)! ), nil)
                }
                
            } // number
            
            // Parse Strings...
            
            if c == "\"" {
                var s = ""
                
                c = _getc()
                
                while c != nil && c != "\"" {
                    
                    if c == "\\" {
                        c = _getc()
                        
                        if !c {
                            return (nil, Error(code: Error.Code.UnterminatedString, location: loc))
                        }
                        
                        var value: String = String(c)
                        
                        switch value {
                            case "b": value = "\u0008"
                            case "f": value = "\u000c"
                            case "n": value = "\n"
                            case "r": value = "\r"
                            case "t": value = "\t"
                            case "u": // parse unicode hex value
                                var hex:String = ""
                                
                                for _ in 0..4 {
                                    let hexChar = _getc()
                                    if !hexChar {
                                        break
                                    }
                                    
                                    hex += String(hexChar)
                                }
                            
                                if let hexInt = JsonValue.hexStringToInt(hex) {
                                    value = String( UnicodeScalar(hexInt) )
                                } else {
                                    return (nil, Error(code: Error.Code.UnexpectedToken, location: _location, token: "\\u\(hex)"))
                                }
                                
                                break
                            default: break // all others just pass through
                        }
                        
                        s += value
                        
                    } else {
                        s += String(c)
                    }
                    
                    c = _getc()
                } // while
                
                if !c {
                    return (nil, Error(code: Error.Code.UnterminatedString, location: loc))
                }
                
                return (Token.StringValue(s), nil)
            } // string
            
            // Parse reserved words...
            
            if c.isAlpha() {
                
                var s = String(c)
                
                c = _getc()
                
                while c != nil && c.isAlpha() {
                    s += String(c)
                    c = _getc()
                }
                
                _ungetc(c)
                
                switch(s) {
                    case "true": return (Token.BoolValue(true), nil)
                    case "false": return (Token.BoolValue(false), nil)
                    case "null": return (Token.Null, nil)
                    default: return (nil, Error(code: Error.Code.UnexpectedToken, location: loc, token: s))
                }
            }
            
            // Anything else is an error
            
            return (nil, Error(code: Error.Code.UnexpectedToken, location: loc, token: String(c)))
        }
        
    }
}



