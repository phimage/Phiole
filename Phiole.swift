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
    
    // Bool to deactivate default colorization
    public var colorize: Bool = true
    public var outputColor: Color = Color.None {
        didSet {
            colorize = true
        }
    }
    public var errorColor: Color = Color.None {
        didSet {
            colorize = true
        }
    }
    
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
        Phiole.writeTo(output, decorate("\(object)", withColor: outputColor) + Phiole.LINE_DELIMITER)
    }
    
    public func print(object: AnyObject) {
        Phiole.writeTo(output, decorate("\(object)", withColor: outputColor))
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
        Phiole.writeTo(error, decorate("\(object)", withColor: errorColor))
    }
    
    public func errorln(object: AnyObject) {
        Phiole.writeTo(error, decorate("\(object)", withColor: errorColor) + Phiole.LINE_DELIMITER)
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
    
    // MARK: coloration and font enhancement
    private struct PhioleColor {
        var red, green, blue: UInt8
    }
    
    // Check if property XcodeColors set for plugin https://github.com/robbiehanson/XcodeColors
    static let XCODE_COLORS: Bool = {
        let dict = NSProcessInfo.processInfo().environment
        if let env = dict["XcodeColors"] as? String  where env == "YES" {
            return true
        }
        return false
        }()
    
    private func decorate(string: String, withColor color: Color) -> String {
        if self.colorize {
            return color.fg(string)
        }
        return string
    }

    public enum Color {
        case Black, Red, Green, Yellow, Blue, Cyan, Purple, Gray,
        DarkGray,BrightRed,BrightGreen,BrightYellow,BrightBlue,BrightMagenta,BrightCyan,White,
        None
        
        public static let allValues = [Black,Red,Green,Yellow,Blue,Cyan,Purple,Gray,
            DarkGray,BrightRed,BrightGreen,BrightYellow,BrightBlue,BrightMagenta,BrightCyan,White,None]
        
        public static let ESCAPE_SEQUENCE = "\u{001b}["
        public static let TERMINAL_COLORS_RESET = "\u{0030}\u{006d}"
        
        public static let XCODE_COLORS_FG = "fg"
        public static let XCODE_COLORS_RESET_FG = "fg;"
        public static let XCODE_COLORS_BG = "bg"
        public static let XCODE_COLORS_RESET_BG = "bg;"
        public static let XCODE_COLORS_RESET = ";"
        
        public static let COLORS_RESET = Phiole.XCODE_COLORS ? XCODE_COLORS_RESET : TERMINAL_COLORS_RESET

        public var foregroundCode: String? {
            if Phiole.XCODE_COLORS {
                if let c = self.xcodeColor {
                    return "\(Color.XCODE_COLORS_FG)\(c.red),\(c.green),\(c.blue);"
                }
                return nil
            }
            switch self {
            case Black  : return "30m"
            case Red    : return "31m"
            case Green  : return "32m"
            case Yellow : return "33m"
            case Blue   : return "34m"
            case Purple : return "35m"
            case Cyan   : return "36m"
            case Gray   : return "37m"
            // bold
            case DarkGray      : return "1;30m"
            case BrightRed     : return "1;31m"
            case BrightGreen   : return "1;32m"
            case BrightYellow  : return "1;33m"
            case BrightBlue    : return "1;34m"
            case BrightMagenta : return "1;35m"
            case BrightCyan    : return "1;36m"
            case White         : return "1;37m"
    
            case None : return nil
            }
        }
        
        public var backgroundCode: String? {
            if Phiole.XCODE_COLORS {
                if let c = self.xcodeColor {
                    return  "\(Color.XCODE_COLORS_BG)\(c.red),\(c.green),\(c.blue);"
                }
                return nil
            }
            switch self {
            case Black  : return "40m"
            case Red    : return "41m"
            case Green  : return "42m"
            case Yellow : return "43m"
            case Blue   : return "44m"
            case Purple : return "45m"
            case Cyan   : return "46m"
            case Gray   : return "47m"
                
            case DarkGray      : return "1;40m"
            case BrightRed     : return "1;41m"
            case BrightGreen   : return "1;42m"
            case BrightYellow  : return "1;43m"
            case BrightBlue    : return "1;44m"
            case BrightMagenta : return "1;45m"
            case BrightCyan    : return "1;46m"
            case White         : return "1;47m"

            case None : return nil
            }
        }

        /*private var terminalColor: PhioleColor? {
            switch self {
            case Black  : return PhioleColor(red:  0,   green: 0,   blue: 0)
            case Red    : return PhioleColor(red:194,  green: 54,  blue: 33)
            case Green  : return PhioleColor(red: 37, green: 188,  blue: 36)
            case Yellow : return PhioleColor(red:173, green: 173,  blue: 39)
            case Blue   : return PhioleColor(red: 73,  green: 46, blue: 225)
            case Purple : return PhioleColor(red:211,  green: 56, blue: 211)
            case Cyan   : return PhioleColor(red: 51, green: 187, blue: 200)
            case Gray   : return PhioleColor(red:203, green: 204, blue: 205)
                
            case DarkGray      : return PhioleColor(red:129, green: 131, blue: 131)
            case BrightRed     : return PhioleColor(red:252,  green: 57,  blue: 31)
            case BrightGreen   : return PhioleColor(red: 49, green: 231,  blue: 34)
            case BrightYellow  : return PhioleColor(red:234, green: 236,  blue: 35)
            case BrightBlue    : return PhioleColor(red: 88,  green: 51, blue: 255)
            case BrightMagenta : return PhioleColor(red:249,  green: 53, blue: 248)
            case BrightCyan    : return PhioleColor(red: 20, green: 240, blue: 240)
            case White         : return PhioleColor(red:233, green: 235, blue: 235)
  
            case None : return nil
            }
        }*/
        private var xcodeColor: PhioleColor? {
            switch self {
            case Black  : return PhioleColor(red:  0,   green: 0,   blue: 0)
            case Red    : return PhioleColor(red:205,   green: 0,   blue: 0)
            case Green  : return PhioleColor(red:  0, green: 205,   blue: 0)
            case Yellow : return PhioleColor(red:205, green: 205,   blue: 0)
            case Blue   : return PhioleColor(red:  0,   green: 0, blue: 238)
            case Purple : return PhioleColor(red:205,   green: 0, blue: 205)
            case Cyan   : return PhioleColor(red:  0, green: 205, blue: 205)
            case Gray   : return PhioleColor(red:229, green: 229, blue: 229)
                
            case DarkGray      : return PhioleColor(red:127, green: 127, blue: 127)
            case BrightRed     : return PhioleColor(red:255,   green: 0,   blue: 0)
            case BrightGreen   : return PhioleColor(red:  0, green: 255,   blue: 0)
            case BrightYellow  : return PhioleColor(red:255, green: 255,   blue: 0)
            case BrightBlue    : return PhioleColor(red: 92,  green: 92, blue: 255)
            case BrightMagenta : return PhioleColor(red:255,   green: 0, blue: 255)
            case BrightCyan    : return PhioleColor(red:  0, green: 255, blue: 255)
            case White         : return PhioleColor(red:255, green: 255, blue: 255)
                
            case None : return nil
            }
        }

        // MARK: functions
        public func fg(string: String) -> String {
            if let code = self.foregroundCode {
                return Color.ESCAPE_SEQUENCE + code + string + Color.ESCAPE_SEQUENCE + Color.COLORS_RESET
            }
            return string
        }
        
        public func bg(string: String) -> String {
            if let code = self.backgroundCode {
                return Color.ESCAPE_SEQUENCE + code + string + Color.ESCAPE_SEQUENCE + Color.COLORS_RESET
            }
            return string
        }
        
        public static func decorate(string: String, fg: Color, bg: Color) -> String {
            if let fcode = fg.foregroundCode, bcode = bg.backgroundCode {
                return Color.ESCAPE_SEQUENCE + fcode + ESCAPE_SEQUENCE + bcode + string + Color.ESCAPE_SEQUENCE + Color.COLORS_RESET
            }
            if fg.foregroundCode != nil {
                return fg.fg(string)
            }
            if bg.backgroundCode != nil {
                return bg.bg(string)
            }
            return string
        }
    }
    
    /*public enum FontStyle {
        case Bold
        case Italic
        case Underline
        case Reverse
        
        public var on: String {
            switch self {
            case Bold      : return "1m"
            case Italic    : return "3m"
            case Underline : return "4m"
            case Reverse   : return "7m"
            }
        }
        
        public var off: String {
            switch self {
            case Bold      : return "22m"
            case Italic    : return "23m"
            case Underline : return "24m"
            case Reverse   : return "27m"
            }
        }
        
        public func decorate(string: String) -> String {
            return self.on + string + self.off
        }
    }*/
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

