//
//  RADAR.swift
//  NTSwiftJson
//
//  Created by Ethan Nagel on 6/10/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

import Foundation


class RadarTests {
    
    
    func getc() -> UnicodeScalar! { return nil }
    
    func Crash5()
    {
        var ch = getc()

        // Causes Compiler Crash
//        while ch && ch.isDigit() {
//            ch = getc()
//        }
        
        // But this works fine
        while ch {
            if ch.isDigit() {
                break
            }
            ch = getc()
        }
    }
}