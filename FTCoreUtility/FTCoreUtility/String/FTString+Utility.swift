//
//  FTString.swift
//  FTMobileCore
//
//  Created by Praveen Prabhakar on 28/07/17.
//  Copyright © 2017 Praveen Prabhakar. All rights reserved.
//

import Foundation

//Enmuration
public extension String {
    
    func enumerate(pattern: String, using block: ((NSTextCheckingResult?) -> Void )? ) {
        
        let exp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        exp?.enumerateMatches(in: self,
                              options: .reportCompletion,
                              range: NSMakeRange(0, self.length),
                              using: { (result, flags, _) in
                                block?(result)
        })
    }
}

//String Size
public extension String {
    
    func trimming(string: String) -> String? {
        return self.replacingOccurrences(of: string, with: "")
    }
    
    func substring(with range: NSRange) -> String? {
        return (self as NSString).substring(with: range) as String! ?? nil
    }
    
    func substring(from fromIndex: Int, to toIndex: Int) -> String? {
        let substring = self.substring(with: NSMakeRange(fromIndex, toIndex - fromIndex))
        return substring
    }
    
    func contains(_ find: String) -> Bool {
        return self.range(of: find) != nil
    }
    
    var length: Int {
        return characters.count
    }
}

//JSON
public extension String {
    
    //Loading Data from given Path
    func JSONContentAtPath() throws -> Any? {
        
        guard let content = try? Data.init(contentsOf: URL.init(fileURLWithPath: self)) else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: content, options: .allowFragments)
    }
}
