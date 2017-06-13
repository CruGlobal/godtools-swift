//
//  TractCardProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCardProperties: TractProperties {
    
    enum CardState {
        case open, preview, close, hidden, enable
    }
    
    // MARK: - XML Properties
    
    var backgroundColor: UIColor?
    var backgroundImage: UIImage?
    var backgroundImageAlign: [TractMainStyle.BackgroundImageAlign] = [.center]
    var backgroundImageScaleType: TractMainStyle.BackgroundImageScaleType = .fill
    var textColor = GTAppDefaultStyle.textColorString.getRGBAColor()
    
    // MARK: - View Properties
    
    var cardState = CardState.preview
    var cardNumber = 0
    
}
