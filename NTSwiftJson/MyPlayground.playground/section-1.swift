// Playground - noun: a place where people can play

import Foundation


//
//  JsonValue.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/10/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


let x: String = ""


enum JsonValue {
    case StringValue(value: String)
    case IntValue(value: Int)
    case DoubleValue(value: Double)
    case BoolValue(value: Bool)
    case ObjectValue(value: Dictionary<String,JsonValue>)
    case ArrayValue(value: JsonValue[])
    case Null
    
}


class JsonParser
{
    var _text: String
    var _current: String.UnicodeScalarView.GeneratorType
    var _ungetBuffer: UnicodeScalar? = nil
    var _error: NSError? = nil
    
    enum Token : Printable {
        case Text(String)           // quoted string
        case Scalar(Int64)          // whole number
        case Real(Double)           // floating point value
        case Boolean(Bool)          // true/false
        case Null                   // uhh yeah.
        
        case Colon                  // :
        case Comma                  // ,
        case StartObject            // {
        case EndObject              // }
        case StartArray             // [
        case EndArray               // ]
        
        case EOF                    // end of string
        
        case Error(String)
        
        
        var description: String {
            return "Token"
        }
    }
    
    
    init(text:String) {
        _text = text
        _current = _text.unicodeScalars.generate()
    }
    
    
    func getc() -> UnicodeScalar! {
        
        if ( _ungetBuffer )
        {
            let value = _ungetBuffer
            _ungetBuffer = nil
            
            return value
        }
        
        return _current.next()
    }
    
    
    func ungetc(c: UnicodeScalar!)
    {
        if _ungetBuffer {
            println("Parser Error - ungetc when buffer is full!")   // how to throw exception or assert here?
        }
        
        if c {
            _ungetBuffer = c
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
    
    
    func getToken() -> Token
    {
        var ch = getc()
        
        return Token.EOF
        
      // note "!c == false" is used in place of "c" in this code to work around a compiler crash :(
        
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
        
        // Parse special characters:
        
        switch String(c) {
        case "{": return Token.StartObject
        case "}": return Token.EndObject
        case "[": return Token.StartArray
        case "]": return Token.EndArray
        case ":": return Token.Colon
        case ",": return Token.Comma
        default: break
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
            
            if !c == false && c == "." {
                isReal = true
                s += "."
                
                c = getc()
                while !c == false && c.isDigit() {
                    s += String(c)
                    c = getc()
                }
            }
            
            // parse exponent...
            
            if !c == false && (c == "e" || c == "E") {
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
                return Token.Real( JsonParser.stringToDouble(s)! )
            } else {
                return Token.Scalar( JsonParser.stringToInt64(s)! )
            }
            
        } // number
        
        // Parse Strings...
        
        if c == "\"" {
            var s = ""
            
            c = getc()
            
            while !c == false && c != "\"" {
                
                if c == "\\" {
                    c = getc()
                    
                    if !c {
                        return Token.Error("Unterminated string encountered") // crap
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
                        
                        value = String( UnicodeScalar( JsonParser.hexStringToInt(hex)! ) )
                        
                        break
                    default: break // all others just pass through
                    }
                    
                    s += value
                    
                } else {
                    s += String(c)
                }
            } // while
            
        } // string
        
        // Parse reserved words...
        
        if c.isAlpha() {
            
            var s = String(c)
            
            c = getc()
            
            while !c == false && c.isAlpha() {
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
    
    
    func parse() -> (value: JsonValue!, error: NSError?) {
        
        printLoop:while(true) {
            let token = getToken()
            
            switch(token) { case .EOF: break printLoop default: break }
            
            print("\(token) ")
        }
        
        println("")
        
        return (nil, nil)
    }
    
    
    func testTokenizer() -> String {
        
        var result = ""
        
        printLoop:while(true) {
            let token = getToken()
            
            switch(token) { case .EOF: break printLoop default: break }
            
            result += "test "
        
        }
        
        return result
    }
    
    
}


var text = "{ \"one\": 1 } "

var parser = JsonParser(text: text)

var result = parser.testTokenizer()






