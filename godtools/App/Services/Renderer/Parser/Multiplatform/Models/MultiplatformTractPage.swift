//
//  MultiplatformTractPage.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformTractPage: PageModelType {
    
    private let tractPage: TractPage
    
    let uuid: String = UUID().uuidString
    
    required init(tractPage: TractPage) {
        
        self.tractPage = tractPage
    }
    
    var backgroundImage: String? {
        return nil // TODO: Need to set this. ~Levi
    }
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        return [] // TODO: Need to set this. ~Levi
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        return .fill // TODO: Need to set this. ~Levi
    }
    
    var listeners: [String] {
        return [] // TODO: Need to set this. ~Levi
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: tractPage.textScale)
    }
    
    var isHidden: Bool {
        return false // TODO: Need to set this. ~Levi
    }
    
    var hero: HeroModelType? {
        return nil // TODO: Need to set this. ~Levi
    }
    
    var callToAction: CallToActionModelType? {
        return nil // TODO: Need to set this. ~Levi
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.backgroundColor)
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.cardTextColor)
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.primaryColor)
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.primaryTextColor)
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.textColor)
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformTractPage {
    
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
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        if let header = tractPage.header {
            childModels.append(MultiplatformHeader(header: header))
        }
        
        if let hero = tractPage.hero {
            childModels.append(MultiplatformHero(hero: hero))
        }
        
        // TODO: Return children to render. ~Levi
        return childModels
    }
}
