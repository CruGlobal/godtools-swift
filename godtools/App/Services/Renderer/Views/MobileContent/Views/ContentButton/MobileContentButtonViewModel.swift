//
//  MobileContentButtonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentButtonViewModel: MobileContentViewModel {
    
    private let maxAllowedIconSize = 40
    
    private let buttonModel: Button
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    let backgroundColor: UIColor
    let buttonWidth: MobileContentViewWidth
    let titleColor: UIColor
    let titleAlignment: NSTextAlignment
    let borderColor: UIColor?
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    let icon: MobileContentButtonIcon?
    
    init(buttonModel: Button, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.buttonModel = buttonModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        buttonWidth = MobileContentViewWidth(dimension: buttonModel.width)
        
        let defaultBackgroundColor: UIColor = buttonModel.buttonColor.toUIColor()
        titleColor = buttonModel.text.textColor.toUIColor()
        let defaultBorderColor: UIColor = .clear
        
        switch buttonModel.text.textAlign {
        case .center:
            titleAlignment = .center
        case .end:
            titleAlignment = .right
        case .start:
            titleAlignment = .left
        default:
            titleAlignment = .center
        }
                                
        switch buttonModel.style {
        
        case .contained:
            backgroundColor = defaultBackgroundColor
            borderColor = defaultBorderColor
            
        case .outlined:
            backgroundColor = buttonModel.backgroundColor.toUIColor()
            borderColor = buttonModel.buttonColor.toUIColor()
            
        case .unknown:
            backgroundColor = defaultBackgroundColor
            borderColor = defaultBorderColor
            
        default:
            backgroundColor = defaultBackgroundColor
            borderColor = defaultBorderColor
        }
                
        if let resource = buttonModel.icon, let image = renderedPageContext.resourcesCache.getUIImage(resource: resource)  {
            
            let iconSize = min(Int(buttonModel.iconSize), maxAllowedIconSize)
                    
            let scaledImage = image.scalePreservingAspectRatio(targetSize: CGSize(width: iconSize, height: iconSize))
            
            self.icon = MobileContentButtonIcon(size: buttonModel.iconSize, gravity: buttonModel.iconGravity, image: scaledImage)
        } else {
            
            self.icon = nil
        }
        
        super.init(baseModel: buttonModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        visibilityFlowWatcher = buttonModel.watchVisibility(state: renderedPageContext.rendererState, block: { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
            let visibilityStateValue: MobileContentViewVisibilityState
            
            if gone.boolValue {
                visibilityStateValue = .gone
            }
            else if invisible.boolValue {
                visibilityStateValue = .hidden
            }
            else {
                visibilityStateValue = .visible
            }
            
            self?.visibilityState.accept(value: visibilityStateValue)
        })
    }
    
    deinit {
        visibilityFlowWatcher?.close()
    }
    
    private var textScale: Double {
        return buttonModel.text.textScale
    }
    
    var font: UIFont {
                
        let fontScale = CGFloat(textScale)
        
        return FontLibrary.systemUIFont(size: fontSize * fontScale, weight: fontWeight)
    }
    
    var title: String? {
        return buttonModel.text.text
    }
    
    var borderWidth: CGFloat? {
        if borderColor == nil {
            return nil
        }
        return 1
    }
}
