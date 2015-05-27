//
//  PhioleColor.swift
//  Phiole
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

// Check if property XcodeColors set for plugin https://github.com/robbiehanson/XcodeColors
let XCODE_COLORS: Bool = {
    let dict = NSProcessInfo.processInfo().environment
    if let env = dict["XcodeColors"] as? String  where env == "YES" {
        return true
    }
    return false
    }()

public extension Phiole {
    
    private struct key {
        static let colorize = UnsafePointer<Void>(bitPattern: Selector("colorize").hashValue)
        static let outputColor = UnsafePointer<Void>(bitPattern: Selector("outputColor").hashValue)
        static let errorColor = UnsafePointer<Void>(bitPattern: Selector("errorColor").hashValue)
    }

    // Bool to deactivate default colorization
    public var colorize: Bool {
        get {
            if let o = objc_getAssociatedObject(self, key.colorize) as? Bool {
                return o
            }
            else {
                let obj = true
                objc_setAssociatedObject(self, key.colorize, obj, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                return obj
            }
        }
        set {
            objc_setAssociatedObject(self, key.colorize, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    public var outputColor: Color {
        get {
            if let o = objc_getAssociatedObject(self, key.outputColor) as? Int {
                return Color(rawValue: o)!
            }
            else {
                let obj = Color.None
                objc_setAssociatedObject(self, key.outputColor, obj.rawValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                return obj
            }
        }
        set {
            objc_setAssociatedObject(self, key.outputColor, newValue.rawValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            colorize = true
        }
    }
    
    public var errorColor: Color {
        get {
            if let o = objc_getAssociatedObject(self, key.errorColor) as? Int {
                return Color(rawValue: o)!
            }
            else {
                let obj = Color.None
                objc_setAssociatedObject(self, key.errorColor, obj.rawValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                return obj
            }
        }
        set {
            objc_setAssociatedObject(self, key.errorColor, newValue.rawValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            colorize = true
        }
    }

    // MARK: coloration and font enhancement
    private struct PhioleColor {
        var red, green, blue: UInt8
    }
    
    public enum Color: Int, StringDecorator {
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
        
        public static let COLORS_RESET = XCODE_COLORS ? XCODE_COLORS_RESET : TERMINAL_COLORS_RESET
        
        public var foregroundCode: String? {
            if XCODE_COLORS {
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
            if XCODE_COLORS {
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
        
        public func decorate(string: String) -> String {
            return fg(string)
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
