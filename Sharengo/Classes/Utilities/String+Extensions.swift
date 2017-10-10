//
//  String+Extensions.swift
//
//  Created by Dedecube on 12/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

/**
 String utilities like md5, decode of html entities, ...
 */
extension String
{
    /// MD5 of a string
    public var md5: String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return (0..<length).map { String(format: "%02x", hash[$0]) }.joined()
    }
    
    /**
     This method decode html entities present in a string (https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references)
     */
    public func htmlDecoded() -> String {
        
        guard (self != "") else { return self }
        
        var newStr = self
        let entities = [
            "&quot;"    : "\"",
            "&amp;"     : "&",
            "&apos;"    : "'",
            "&lt;"      : "<",
            "&gt;"      : ">",
            "&deg;"     : "º",
            "&nbsp;"    : " ",
            ]
        
        for (name,value) in entities {
            newStr = newStr.replacingOccurrences(of: name, with: value)
        }
        return newStr
    }
}
