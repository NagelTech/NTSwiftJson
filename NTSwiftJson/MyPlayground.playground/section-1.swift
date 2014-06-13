

import Foundation



let x = "Hello"

x.uppercaseString

var y: String? = nil


class Test {
    var string = "Hello"
}


func getTest() -> Test? { return nil }


if let temp = getTest()?.string {
    println("temp = \(temp)")
} else {
    println("temp is nil")
}




