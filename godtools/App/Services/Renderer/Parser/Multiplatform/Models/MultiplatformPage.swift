//
//  MultiplatformPage.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformPage: PageModelType {
    
    let uuid: String = UUID().uuidString
    
    required init() {
        
    }
    
    var backgroundImage: String? {
        return nil // TODO: Set this. ~Levi
    }
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        return [] // TODO: Set this. ~Levi
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        return .fill // TODO: Set this. ~Levi
    }
    
    var listeners: [String] {
        return [] // TODO: Set this. ~Levi
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: 1) // TODO: Set this. ~Levi
    }
    
    var isHidden: Bool {
        return false // TODO: Set this. ~Levi
    }
    
    var hero: HeroModelType? {
        return nil // TODO: Set this. ~Levi
    }
    
    var callToAction: CallToActionModelType? {
        return nil // TODO: Set this. ~Levi
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return nil // TODO: Set this. ~Levi
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return nil // TODO: Set this. ~Levi
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return nil // TODO: Set this. ~Levi
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return nil // TODO: Set this. ~Levi
    }
    
    func getTextColor() -> MobileContentColor? {
        return nil // TODO: Set this. ~Levi
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformPage {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
