//
//  SHA256FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // This should be removed in place of ResourcesSHA256FileCache now pointing to a FileCache following work in GT-1448. ~Levi
class SHA256FileLocation: FileCacheLocation {
    
    private static let supportedExtensions: [String] = ["png", "jpg", "xml", "txt", "zip", "json"]
    
    let sha256: String
    let pathExtension: String
    
    init(sha256: String, pathExtension: String) {
        
        if SHA256FileLocation.isValidPathExtension(pathExtension: pathExtension) {
            self.sha256 = sha256
            self.pathExtension = pathExtension
        }
        else {
            self.sha256 = sha256
            self.pathExtension = ""
        }
        
        super.init(relativeUrlString: sha256)
    }
    
    init(sha256WithPathExtension: String) {
        
        if let file = URL(string: sha256WithPathExtension) {
            
            let pathExtension: String = file.pathExtension
            let isValidPathExtension: Bool = SHA256FileLocation.isValidPathExtension(pathExtension: pathExtension)
            
            if isValidPathExtension {
                self.sha256 = file.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
                self.pathExtension = pathExtension
                
                super.init(relativeUrlString: sha256 + "." + pathExtension)
            }
            else if file.path.contains(pathExtension) {
                self.sha256 = file.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
                self.pathExtension = ""
                
                super.init(relativeUrlString: sha256)
            }
            else {
                self.sha256 = file.path
                self.pathExtension = ""
                
                super.init(relativeUrlString: sha256)
            }
        }
        else {
            self.sha256 = ""
            self.pathExtension = ""
            
            super.init(relativeUrlString: "")
        }
    }
    
    private static func isValidPathExtension(pathExtension: String) -> Bool {
        return !pathExtension.isEmpty && !pathExtension.contains(" ") && SHA256FileLocation.supportedExtensions.contains(pathExtension)
    }
    
    var sha256WithPathExtension: String {
        if SHA256FileLocation.isValidPathExtension(pathExtension: pathExtension) {
            return sha256 + "." + pathExtension
        }
        else {
           return sha256
        }
    }
}
