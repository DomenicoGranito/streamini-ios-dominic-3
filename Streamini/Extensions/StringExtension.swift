//
//  StringExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension String {
    func handleEmoji() -> String {
        let emojies =
        [
            ":)": "\u{1F60A}", ":-)": "\u{1F60A}",
            ":(": "\u{1F61E}", ":-(": "\u{1F61E}",
            ";)": "\u{1F609}", ";-)": "\u{1F609}",
            ":D": "\u{1F603}", ":-D": "\u{1F603}", ":d": "\u{1F603}", ":-d": "\u{1F603}",
            ":P": "\u{1F60B}", ":-P": "\u{1F60B}", ":p": "\u{1F60B}", ":-p": "\u{1F60B}"
        ]
        
        var string = self
        for e in emojies {
            string = string.stringByReplacingOccurrencesOfString(e.0, withString: e.1)
        }
        
        return string
    }
}