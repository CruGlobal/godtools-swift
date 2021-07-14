//
//  BackgroundImageNodeType.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol BackgroundImageNodeType {
    
    var backgroundImage: String? { get }
    var backgroundImageAlign: [String] { get }
    var backgroundImageScaleType: String { get }
}

extension BackgroundImageNodeType {
    
    var backgroundImageExists: Bool {
        if let backgroundImage = self.backgroundImage {
            return !backgroundImage.isEmpty
        }
        return false
    }
}
