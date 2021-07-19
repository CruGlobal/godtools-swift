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
    
    var backgroundColor: UIColor? {
        return tractPage.backgroundColor
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
    
    func getBackgroundColor() -> UIColor? {
        return tractPage.backgroundColor
    }
    
    func getCardTextColor() -> UIColor? {
        return tractPage.cardTextColor
    }
    
    func getPrimaryColor() -> UIColor? {
        return tractPage.primaryColor
    }
    
    func getPrimaryTextColor() -> UIColor? {
        return tractPage.primaryTextColor
    }
    
    func getTextColor() -> UIColor? {
        return tractPage.textColor
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
}
