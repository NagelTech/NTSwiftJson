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
        case Text(String)           // quoted string
        case Scalar(Int64)          // whole number
        case Real(Double)           // floating point value
        case Boolean(Bool)          // true/false
        case Null                   // uhh yeah.
        case Op(Operator)           //
        case EOF                    // end of string
        
        case Error(String)
        
        var description: String {
            switch(self) {
                case .Text(let value): return "\"\(value)\""
                case .Scalar(let value): return "\(value)"
                case .Real(let value): return "\(value)"
                case .Boolean(let value): return "\(value)"
                case .Null: return "null"
                case .Op(let value): return "\(value.toRaw())"
                case .EOF: return "<<EOF>>"
                case .Error(let message): return "parser Error - \(message)"
            }
        }
        
        
        var isEOF: Bool {
        switch(self) {
        case .EOF: return true
        default: return false
            }
        }
        
        
        var isError: Bool {
            switch(self) {
                case .Error: return true
                default: return false
            }
        }
        
        
        var isText: Bool {
            switch(self) {
                case .Text: return true
                default: return false
            }
        }
        
        var asText: String? {
            switch(self) {
                case .Text(let value): return value
                default: return nil
            }
        }
        
        
        var isValue: Bool {
            switch(self) {
                case .Text, .Scalar, .Real, .Boolean, .Null: return true
                default: return false
            }
        }
        
        
        var asValue: JsonValue? {
            switch(self) {
                case .Text(let value): return JsonValue.StringValue(value)
                case .Scalar(let value): return JsonValue.IntValue(value)
                case .Real(let value): return JsonValue.DoubleValue(value)
                case .Boolean(let value): return JsonValue.BoolValue(value)
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
    
    
    class Tokenizer {
        var _current: String.UnicodeScalarView.GeneratorType
        var _ungetcBuffer: UnicodeScalar? = nil
        var _ungetTokenBuffer: Token? = nil
        
        init(text:String) {
            _current = text.unicodeScalars.generate()
        }
        
        
        func getc() -> UnicodeScalar! {
            
            if ( _ungetcBuffer )
            {
                let value = _ungetcBuffer
                _ungetcBuffer = nil
                
                return value
            }
            
            return _current.next()
        }
        
        
        func ungetc(c: UnicodeScalar!)
        {
            if _ungetcBuffer {
                println("Parser Error - ungetc when buffer is full!")   // how to throw exception or assert here?
            }
            
            if c {
                _ungetcBuffer = c
            }
        }
        
        
        class func stringToInt64(string: String) -> Int64!
        {
            let s = NSScanner(string: string)
            
            var result: Int64 = 0
            
            return s.scanLongLong(&result) ? result : nil
        }
        
        
        class func stringToDouble(string: String) -> Double!
        {
            let s = NSScanner(string: string)
            
            var result: Double = 0
            
            return s.scanDouble(&result) ? result : nil
        }
        
        
        class func hexStringToInt(hexString: String) -> UInt32!
        {
            let s = NSScanner(string: hexString)
            
            var result: CUnsignedInt = 0
            
            return s.scanHexInt(&result) ? UInt32(result) : nil
        }
        
        
        func ungetToken(token: Token) {
            if _ungetTokenBuffer {
                println("Parser Error - ungetToken when buffer is full!")   // how to throw exception or assert here?
            }
            
            _ungetTokenBuffer = token
        }
        
        
        func getToken() -> Token
        {
            if ( _ungetTokenBuffer )
            {
                let value = _ungetTokenBuffer
                _ungetTokenBuffer = nil
                
                return value!
            }
            
            // First, skip any spaces...
            
            while let c = getc() {
                if !c.isSpace() {
                    ungetc(c)
                    break
                }
            }
            
            var c = getc()
            
            if !c {
                return Token.EOF  // no remaining tokens
            }
            
            // Parse operators (all are single char)...
            
            if let operator = Operator.fromRaw(String(c)) {
                return Token.Op(operator)
            }
            
            // Parse Numbers...
            
            if c.isDigit() || c == "+" || c == "-" {
                
                var s = String(c)
                var isReal = false
                
                // parse initial digits...
                
                c = getc()
                
                while !c == false && c.isDigit() {
                    s += String(c)
                    c = getc()
                }
                
                // parse fraction...
                
                if c != nil && c == "." {
                    isReal = true
                    s += "."
                    
                    c = getc()
                    while !c == false && c.isDigit() {
                        s += String(c)
                        c = getc()
                    }
                }
                
                // parse exponent...
                
                if c != nil && (c == "e" || c == "E") {
                    isReal = true
                    
                    s += String(c)
                    
                    c = getc()
                    
                    if !c == false && (c == "+" || c == "-") {
                        s += String(c)
                        c = getc()
                    }
                    
                    while !c == false && c.isDigit() {
                        s += String(c)
                        c = getc()
                    }
                }
                
                ungetc(c)
                
                if isReal {
                    return Token.Real( Tokenizer.stringToDouble(s)! )
                } else {
                    return Token.Scalar( Tokenizer.stringToInt64(s)! )
                }
                
            } // number
            
            // Parse Strings...
            
            if c == "\"" {
                var s = ""
                
                c = getc()
                
                while c != nil && c != "\"" {
                    
                    if c == "\\" {
                        c = getc()
                        
                        if !c {
                            return Token.Error("Unterminated string encountered")
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
                                    let hexChar = getc()
                                    if !hexChar {
                                        break
                                    }
                                    
                                    hex += String(hexChar)
                                }
                                
                                value = String( UnicodeScalar( Tokenizer.hexStringToInt(hex)! ) )
                                
                                break
                            default: break // all others just pass through
                        }
                        
                        s += value
                        
                    } else {
                        s += String(c)
                    }
                    
                    c = getc()
                } // while
                
                if !c {
                    return Token.Error("Unterminated string encountered")
                }
                
                return Token.Text(s)
            } // string
            
            // Parse reserved words...
            
            if c.isAlpha() {
                
                var s = String(c)
                
                c = getc()
                
                while c != nil && c.isAlpha() {
                    s += String(c)
                    c = getc()
                }
                
                ungetc(c)
                
                switch(s) {
                case "true": return Token.Boolean(true)
                case "false": return Token.Boolean(false)
                case "null": return Token.Null
                default: Token.Error("Unexpected token: \(s)")
                }
            }
            
            // Anything else is an error
            
            return Token.Error("Unexpected character: \(c)")
        }
        
    }
}



