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
    
    var backgroundImageAlign: [String] {
        return [] // TODO: Need to set this. ~Levi
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        return .fill // TODO: Need to set this. ~Levi
    }
    
    var cardTextColor: UIColor? {
        return tractPage.cardTextColor
    }
    
    var listeners: [String] {
        return [] // TODO: Need to set this. ~Levi
    }
    
    var primaryColor: UIColor? {
        return tractPage.primaryColor
    }
    
    var primaryTextColor: UIColor? {
        return tractPage.primaryTextColor
    }
    
    var textColor: UIColor? {
        return tractPage.textColor
    }
    
    var textScale: Double {
        return tractPage.textScale
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
