//
//  main.swift
//  Console
//
//  Created by phimage on 24/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

Console.std.println("Type something and valid")
if let line = Console.std.readline()  where !line.isEmpty{
    Console.std.print("you write:")
    Console.std.print(line)
    Console.std.println()
}
else {
     Console.std.errorln("you don't write")
}


Console.std.println("Type something else, and 'quit' to stop")
Console.std.readlines { (line) -> Bool in
    if line == "quit" {
        return true // stop
    }
    Console.std.println("... again (you write: \(line))")
    return false
}

// all std output in std error
var errconsole = Console.std.withOutput(Console.std.error)
// var errconsole = Console(input: Console.std.input, output: Console.std.error, error: Console.std.error)
Console.std.println("error")
  