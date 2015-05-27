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

public class Phiole: NSObject {

    public static let LINE_DELIMITER = "\n"

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

    // reader for input file handle
    private var reader: FileHandleReader? = nil
    
    
    // MARK: init
    public init(input: NSFileHandle, output: NSFileHandle, error: NSFileHandle) {
        self.input = input
        self.output = output
        self.error = error
        
        if input != NSFileHandle.fileHandleWithStandardInput() {
            self.reader = FileHandleReader(fileHandle: input, delimiter: Phiole.LINE_DELIMITER)
        }
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
        Phiole.writeTo(output, Phiole.LINE_DELIMITER)
    }
    
    public func println() {
         newln()
    }

    public func println(object: AnyObject) {
        Phiole.writeTo(output, decorateOutput(object) + Phiole.LINE_DELIMITER)
    }
    
    public func print(object: AnyObject) {
        Phiole.writeTo(output, decorateOutput(object))
    }

    public func readline() -> String? {
        if let r = reader {
            return r.readLine()
        }
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
        Phiole.writeTo(error, decorateError(object))
    }
    
    public func errorln(object: AnyObject) {
        Phiole.writeTo(error, decorateError(object) + Phiole.LINE_DELIMITER)
    }
    
    // MARK: class func
    public class func writeTo(handle: NSFileHandle, _ string: String) {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            handle.writeData(data)
        }
    }
    
    public class func readFrom(handle: NSFileHandle) -> String? {
        if let str = NSString(data: handle.availableData, encoding:NSUTF8StringEncoding) {
            return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as String
        }
        return nil
    }
    
    // MARK: optional decoration method, could be removed when copying to speed up code
    private func decorateOutput(object: AnyObject) -> String {
        return decorate("\(object)", withColor: self.valueForKey("outputColor"))
    }
    private func decorateError(object: AnyObject) -> String {
        return decorate("\(object)", withColor: self.valueForKey("errorColor"))
    }
    private func decorate(string: String, withColor color: AnyObject?) -> String {
        if let decorator = color as? StringDecorator, colorize = self.valueForKey("colorize") as? Bool where colorize  {
            return decorator.decorate(string)
        }
        return string
    }
    public override func valueForUndefinedKey(key: String) -> AnyObject? {
        if key == "errorColor" || key == "outputColor" || key == "colorize" {
            return nil
        }
        return super.valueForUndefinedKey(key)
    }
    
}
protocol StringDecorator {
    func decorate(string: String) -> String
}
private class FileHandleReader  {
    
    var fileHandle : NSFileHandle
    let encoding : UInt
    let chunkSize : Int
    
    let delimData : NSData!
    let buffer : NSMutableData!
    var atEof : Bool = false
    
    init?(fileHandle: NSFileHandle, delimiter: String, encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096) {
        self.fileHandle = fileHandle
        self.encoding = encoding
        self.chunkSize = chunkSize
        
        if let  delimData = delimiter.dataUsingEncoding(encoding),
            buffer = NSMutableData(capacity: chunkSize)
        {
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    // Return next line, or nil on EOF.
    func readLine() -> String? {
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found
        var range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            var tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // last line
                    let line = NSString(data: buffer, encoding: encoding)
                    buffer.length = 0
                    return line as String?
                }
                // No more lines
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        }
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
            encoding: encoding)
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        return line as String?
    }
}

typealias Φole = Phiole
//typealias Console = Phiole

