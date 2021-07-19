//
//  BackgroundImageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol BackgroundImageModelType {
    
    var backgroundImage: String? { get }
    var backgroundImageAlign: [String] { get }
    var backgroundImageScaleType: String { get }
}

extension BackgroundImageModelType {
    
    var backgroundImageExists: Bool {
        if let backgroundImage = self.backgroundImage {
            return !backgroundImage.isEmpty
        }
        return false
    }
}
