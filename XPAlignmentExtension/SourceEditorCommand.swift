//
//  SourceEditorCommand.swift
//  XPAlignmentExtension
//
//  Created by xinpinghuang on 16/6/16.
//  Copyright © 2016年 huangxinping. All rights reserved.
//

import Foundation
import XcodeKit



class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (NSError?) -> Void ) -> Void {
        
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: "XPAlignmentExtension", code: -1, userInfo: [NSLocalizedDescriptionKey: "None selection"]))
            return
        }
        var regex: RegularExpression?
        do {
            regex = try RegularExpression(pattern: " *=", options: .caseInsensitive)
        } catch _ {
            completionHandler(NSError(domain: "SampleExtension", code: -1, userInfo: [NSLocalizedDescriptionKey: ""]))
            return
        }
        
        let alignPosition = invocation.buffer.lines.enumerated().map { i, line -> Int in
            guard i >= selection.start.line && i <= selection.end.line,
                let line = line as? String,
                result = regex?.firstMatch(in: line, options: .reportProgress, range: NSRange(location: 0, length: line.characters.count)) else {
                    return 0
            }
            return result.range.location
            }.max()
        
        for index in selection.start.line ... selection.end.line {
            guard let line = invocation.buffer.lines[index] as? NSString else {
                continue
            }
            
            let range = line.range(of: "=")
            if range.location != NSNotFound {
                let repeatCount = alignPosition! - range.location + 1
                if repeatCount != 0 {
                    let whiteSpaces = String(repeating: Character(" "), count: abs(repeatCount))
                    
                    if repeatCount > 0 {
                        invocation.buffer.lines.replaceObject(at: index, with: line.replacingOccurrences(of: "= ", with: "\(whiteSpaces)="))
                    } else {
                        invocation.buffer.lines.replaceObject(at: index, with: line.replacingOccurrences(of: "\(whiteSpaces)=", with: "= "))
                    }
                }
            }
        }
        
        completionHandler(nil)
    }
    
}
