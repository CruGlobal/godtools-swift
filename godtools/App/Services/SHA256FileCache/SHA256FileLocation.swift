//
//  SHA256FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct SHA256FileLocation {
    
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
    }
    
    init(sha256WithPathExtension: String) {
        
        if let file = URL(string: sha256WithPathExtension) {
            
            let pathExtension: String = file.pathExtension
            let isValidPathExtension: Bool = SHA256FileLocation.isValidPathExtension(pathExtension: pathExtension)
            
            if isValidPathExtension {
                self.sha256 = file.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
                self.pathExtension = pathExtension
            }
            else if file.path.contains(pathExtension) {
                self.sha256 = file.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
                self.pathExtension = ""
            }
            else {
                self.sha256 = file.path
                self.pathExtension = ""
            }
        }
        else {
            self.sha256 = ""
            self.pathExtension = ""
        }
    }
    
    private static func isValidPathExtension(pathExtension: String) -> Bool {
        return !pathExtension.isEmpty && !pathExtension.contains(" ") && SHA256FileLocation.supportedExtensions.contains(pathExtension)
    }
    
    var fileUrl: URL? {
        
        if SHA256FileLocation.isValidPathExtension(pathExtension: pathExtension) {
            return URL(string: sha256)?.appendingPathExtension(pathExtension)
        }
        else {
           return URL(string: sha256)
        }
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
