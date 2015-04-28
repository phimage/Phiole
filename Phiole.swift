//
//  Phiole.swift
//  2015 Eric Marchand (phimage)
//
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

public class Phiole {

    // MARK: singleton
    public class var std : Phiole {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Phiole? = nil
        }
        dispatch_once(&Static.onceToken) {
            let stdin = NSFileHandle.fileHandleWithStandardInput()
            let stdout = NSFileHandle.fileHandleWithStandardOutput()
            let stderr = NSFileHandle.fileHandleWithStandardError()
            Static.instance = Phiole(input:stdin, output: stdout, error: stderr)
        }
        return Static.instance!
    }
    
    // MARK: vars
    public var input: NSFileHandle
    public var output: NSFileHandle
    public var error: NSFileHandle
    
    // MARK: init
    public init(input: NSFileHandle, output: NSFileHandle, error: NSFileHandle) {
        self.input = input
        self.output = output
        self.error = error
    }
    
    // MARK: clone altered
    public func withOutput(output: NSFileHandle) -> Phiole {
        return Phiole(input: self.input, output: output, error: self.error)
    }
    
    public func withError(error: NSFileHandle) -> Phiole {
        return Phiole(input: self.input, output: self.output, error: error)
    }

    public func withInput(input: NSFileHandle) -> Phiole {
        return Phiole(input: input, output: self.output, error: self.error)
    }
    
    // MARK: functions
    
    public func newln() {
        Phiole.writeTo(output, "\n")
    }
    
    public func println() {
         newln()
    }
    
    public func println(object: AnyObject) {
        Phiole.writeTo(output, "\(object)\n")
    }
    
    public func print(object: AnyObject) {
        Phiole.writeTo(output, "\(object)")
    }
    
    public func readline() -> String? {
        // TODO: work with files, not only standards input by reading in buffer and look for newlineCharacter
        return Phiole.readFrom(self.input)
    }
    
    public func readlines(stopClosure: (String) -> Bool) {
        var line = readline()
        while line != nil {
            if stopClosure(line!) {
                return
            }
            line = readline()
        }
    }
    
    public func error(object: AnyObject) {
        Phiole.writeTo(error, "\(object)")
    }
    
    public func errorln(object: AnyObject) {
        Phiole.writeTo(error, "\(object)\n")
    }
    
    // MARK: privates
    public class func writeTo(handle: NSFileHandle, _ string: String) {
        handle.writeData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    public class func readFrom(handle: NSFileHandle) -> String? {
        if let str = NSString(data: handle.availableData, encoding:NSUTF8StringEncoding) {
            return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as String
        }
        return nil
    }
    
}

typealias Φole = Phiole
//typealias Console = Phiole

