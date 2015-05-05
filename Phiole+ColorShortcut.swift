//
//  Phiole+ColorShortcut.swift
//  Phiole
//
//  Created by phimage on 05/05/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

// MARK : Color shortcut: one to decorate, the other to decorate and print
public extension Phiole {

    public class func red(string: String) -> String {
        return Phiole.Color.Red.fg(string)
    }
    public func prred(string : String) {
        print(Phiole.red(string))
    }

    public class func green(string: String) -> String {
        return Phiole.Color.Green.fg(string)
    }
    public func prgreen(string : String) {
        print(Phiole.green(string))
    }

    public class func yellow(string: String) -> String {
        return Phiole.Color.Yellow.fg(string)
    }
    public func pryellow(string : String) {
        print(Phiole.yellow(string))
    }

    public class func blue(string: String) -> String {
        return Phiole.Color.Red.fg(string)
    }
    public func prblue(string : String) {
        print(Phiole.blue(string))
    }
 
}