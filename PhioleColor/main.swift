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
csl.errorColor = .Red

csl.println("Type something and valid")
if let line = csl.readline()  where !line.isEmpty{
    csl.print("you write:")
    csl.print(line)
    csl.println()
}
else {
    csl.errorln("you don't write")
}


csl.outputColor = .BrightGreen
csl.println(Console.Color.BrightGreen.fg("Type something else, and 'quit' to stop"))
csl.outputColor = Console.Color.Yellow
csl.readlines { (line) -> Bool in
    if line == "quit" {
        return true // stop
    }
    csl.println("... again (you write: \(line))")
    csl.colorize = !csl.colorize
    return false
}

// all std output in std error
let errconsole = csl.withOutput(Console.std.error)
errconsole.outputColor = .Red
errconsole.errorColor = .Red
// var errconsole = Console(input: Console.std.input, output: Console.std.error, error: Console.std.error)
errconsole.println("write to std error")

// write to a file
csl.outputColor = .None
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

