//
//  Console.swift
//  Console
//
//  Created by phimage on 24/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

public class Console {

    // MARK: singleton
    public class var std : Console {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Console? = nil
        }
        dispatch_once(&Static.onceToken) {
            let stdin = NSFileHandle.fileHandleWithStandardInput()
            let stdout = NSFileHandle.fileHandleWithStandardOutput()
            let stderr = NSFileHandle.fileHandleWithStandardError()
            Static.instance = Console(input:stdin, output: stdout, error: stderr)
        }
        return Static.instance!
    }
    
    // MARK: vars
    public var input: NSFileHandle
    public var output:NSFileHandle
    public var error: NSFileHandle
    
    // MARK: init
    public init(input: NSFileHandle, output: NSFileHandle, error: NSFileHandle) {
        self.input = input
        self.output = output
        self.error = error
    }
    
    // MARK: clone altered
    func withOutput(output: NSFileHandle) -> Console {
        return Console(input: self.input, output: output, error: self.error)
    }
    
    func withError(error: NSFileHandle) -> Console {
        return Console(input: self.input, output: self.output, error: error)
    }

    func withInput(input: NSFileHandle) -> Console {
        return Console(input: input, output: self.output, error: self.error)
    }
    
    // MARK: functions
    
    public func newln() {
        writeTo(output, "\n")
    }
    
    public func println() {
         newln()
    }
    
    public func println(object: AnyObject) {
        writeTo(output, "\(object)\n")
    }
    
    public func print(object: AnyObject) {
        writeTo(output, "\(object)")
    }
    
    public func readline() -> String? {
        // TODO: work with files, not only standards input by reading in buffer and look for newlineCharacter

        if let str = NSString(data: self.input.availableData, encoding:NSUTF8StringEncoding) {
            return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as String
        }
        return nil
    }
    
    func readlines(stopClosure: (String) -> Bool) {
        var line = readline()
        while line != nil {
            if stopClosure(line!) {
                return
            }
            line = readline()
        }
    }
    
    public func error(object: AnyObject) {
        writeTo(error, "\(object)")
    }
    
    public func errorln(object: AnyObject) {
        writeTo(error, "\(object)\n")
    }
    
    // MARK: privates
    private func writeTo(handle: NSFileHandle, _ string: String) {
        handle.writeData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
}