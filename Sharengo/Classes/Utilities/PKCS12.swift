//
//  PKCS12.swift
//  Sharengo
//
//  Created by Dedecube on 24/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation

/**
 String utilities like md5, decode of html entities, ...
 */
public class PKCS12 {
    fileprivate var label:String?
    fileprivate var keyID:Data?
    fileprivate var trust:SecTrust?
    fileprivate var certChain:[SecTrust]?
    fileprivate var identity:SecIdentity?
    fileprivate let securityError:OSStatus
    
    // MARK: - Init methods
    
    public init(data:Data, password:String) {
        var items:CFArray?
        let certOptions:NSDictionary = [kSecImportExportPassphrase as NSString:password as NSString]
        self.securityError = SecPKCS12Import(data as NSData, certOptions, &items);
        
        if securityError == errSecSuccess {
            let certItems:Array = (items! as Array)
            let dict:Dictionary<String, AnyObject> = certItems.first! as! Dictionary<String, AnyObject>;
            self.label = dict[kSecImportItemLabel as String] as? String;
            self.keyID = dict[kSecImportItemKeyID as String] as? Data;
            self.trust = dict[kSecImportItemTrust as String] as! SecTrust?;
            self.certChain = dict[kSecImportItemCertChain as String] as? Array<SecTrust>;
            self.identity = dict[kSecImportItemIdentity as String] as! SecIdentity?;
        }
    }
    
    public convenience init(mainBundleResource:String, resourceType:String, password:String) {
        self.init(data: NSData(contentsOfFile: Bundle.main.path(forResource: mainBundleResource, ofType:resourceType)!)! as Data, password: password);
    }
    
    // MARK: - Utility methods
    
    /**
     This method return URL Credential from certificate and identity
     */
    public func urlCredential() -> URLCredential  {
        return URLCredential(
            identity: self.identity!,
            certificates: self.certChain!,
            persistence: URLCredential.Persistence.forSession);
        
    }
}
