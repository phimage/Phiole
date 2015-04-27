//
//  main.swift
//  Console
//
//  Created by phimage on 24/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation
typealias Console = Phiole

let csl = Console.std

csl.println("Type something and valid")
if let line = csl.readline()  where !line.isEmpty{
    csl.print("you write:")
    csl.print(line)
    csl.println()
}
else {
     csl.errorln("you don't write")
}


csl.println("Type something else, and 'quit' to stop")
csl.readlines { (line) -> Bool in
    if line == "quit" {
        return true // stop
    }
    Console.std.println("... again (you write: \(line))")
    return false
}

// all std output in std error
let errconsole = csl.withOutput(Console.std.error)
// var errconsole = Console(input: Console.std.input, output: Console.std.error, error: Console.std.error)
errconsole.println("error writen")


// write to a file
var filePath = "/tmp/phioletest.output"
NSFileManager.defaultManager().createFileAtPath(filePath,contents:nil, attributes:nil)
if let fileHandle = NSFileHandle(forWritingAtPath: filePath) {
    var fileConsole = csl.withOutput(fileHandle)
    
    csl.println("Writing to file : ")
    fileConsole.println("Lorem Ipsum")
    
    fileHandle.closeFile()
    
    if let fileHandleInput = NSFileHandle(forReadingAtPath: filePath){
        var fileConsole = fileConsole.withInput(fileHandleInput)
        if let line = fileConsole.readline() {
            csl.println("Reading from file : \(line)")
            
        }else {
            csl.errorln("no input")
        }
        fileHandleInput.closeFile()
    }
    
}

