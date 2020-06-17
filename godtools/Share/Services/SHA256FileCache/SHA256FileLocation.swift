//
//  SHA256FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct SHA256FileLocation {
    
    let sha256: String
    let pathExtension: String
    
    init(sha256: String, pathExtension: String) {
        
        self.sha256 = sha256
        self.pathExtension = pathExtension
    }
    
    init(sha256WithPathExtension: String) {
        
        if let file = URL(string: sha256WithPathExtension) {
            
            self.pathExtension = file.pathExtension
            
            if !pathExtension.isEmpty {
                self.sha256 = file.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
            }
            else {
                self.sha256 = file.path
            }
        }
        else {
            assertionFailure("Invalid sha256WithPathExtension.")
            self.sha256 = ""
            self.pathExtension = ""
        }
    }
    
    var fileUrl: URL? {
        return URL(string: sha256)?.appendingPathExtension(pathExtension)
    }
    
    var sha256WithPathExtension: String {
        return sha256 + "." + pathExtension
    }
}
