//
//  MobileContentButtonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentButtonViewModel: NSObject, MobileContentButtonViewModelType {
    
    private let maxAllowedIconSize = 40
    
    private let buttonModel: Button
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerModel: MobileContentRenderableModelContainer?
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let backgroundColor: UIColor
    let buttonWidth: MobileContentViewWidth
    let titleColor: UIColor
    let borderColor: UIColor?
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    let icon: MobileContentButtonIcon?
    
    required init(buttonModel: Button, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.buttonModel = buttonModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        
        buttonWidth = MobileContentViewWidth(dimension: buttonModel.width)
        
        let buttonColor: UIColor = buttonModel.buttonColor
        let buttonTitleColor: UIColor? = buttonModel.text?.textColor
                
        switch buttonModel.style {
        
        case .contained:
            backgroundColor = buttonColor
            titleColor = buttonTitleColor ?? rendererPageModel.pageColors.primaryTextColor
            borderColor = UIColor.clear
        case .outlined:
            backgroundColor = buttonModel.backgroundColor
            titleColor = buttonColor
            borderColor = buttonColor
        case .unknown:
            backgroundColor = buttonColor
            titleColor = buttonTitleColor ?? rendererPageModel.pageColors.primaryTextColor
            borderColor = UIColor.clear
        default:
            backgroundColor = buttonColor
            titleColor = buttonTitleColor ?? rendererPageModel.pageColors.primaryTextColor
            borderColor = UIColor.clear
        }
        
        if let name = buttonModel.icon?.name,
            let image = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: name)  {
            
            let iconSize = min(Int(buttonModel.iconSize), maxAllowedIconSize)
                    
            let scaledImage = image.scalePreservingAspectRatio(targetSize: CGSize(width: iconSize, height: iconSize))
            
            self.icon = MobileContentButtonIcon(size: buttonModel.iconSize, gravity: buttonModel.iconGravity, image: scaledImage)
        } else {
            
            self.icon = nil
        }
        
        super.init()
        
        visibilityFlowWatcher = buttonModel.watchVisibility(state: rendererPageModel.rendererState, block: { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
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
    
    var font: UIFont {
        
        let fontScale = CGFloat(buttonModel.textScale)
        
        return fontService.getFont(
            size: fontSize * fontScale,
            weight: fontWeight
        )
    }
    
    var title: String? {
        return buttonModel.text?.text
    }
    
    var borderWidth: CGFloat? {
        if borderColor == nil {
            return nil
        }
        return 1
    }
    
    var buttonType: Button.Type_ {
        return buttonModel.type
    }
    
    var buttonEvents: [EventId] {
        return buttonModel.events
    }
    
    var buttonUrl: String {
        return buttonModel.url?.absoluteString ?? ""
    }
    
    var rendererState: State {
        return rendererPageModel.rendererState
    }
    
    func buttonTapped() {
        
        let analyticsEvents: [AnalyticsEventModelType] = buttonModel.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
        
        mobileContentAnalytics.trackEvents(events: analyticsEvents, rendererPageModel: rendererPageModel)
    }
}
