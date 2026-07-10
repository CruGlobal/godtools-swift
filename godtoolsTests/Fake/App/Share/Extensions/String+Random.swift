//
//  String+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension String {
    
    static func random(length: Int = Int.random()) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let stringElements = (0 ..< length).compactMap { _ in
            letters.randomElement()
        }
        
        return String(stringElements)
    }
}
