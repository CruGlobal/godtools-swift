//
//  MultiplatformContentButton.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentButton: ContentButtonModelType {
    
    private let button: Button
    
    required init(button: Button) {
        
        self.button = button
    }
    
    var events: [MultiplatformEventId] {
        return button.events.map({MultiplatformEventId(eventId: $0)})
    }
    
    var url: String? {
        return button.url?.absoluteString
    }
    
    var style: MobileContentButtonStyle? {
        
        let defaultStyle: MobileContentButtonStyle = .contained
        
        switch button.style {
        case .contained:
            return .contained
        case .outlined:
            return .outlined
        case .unknown:
            return defaultStyle
        default:
            assertionFailure("Returning unsupported type.  Check that we are providing values for all button.style enum values.")
            return defaultStyle
        }
    }
    
    var type: MobileContentButtonType {
        switch button.type {
        case .event:
            return .event
        case .url:
            return .url
        case .unknown:
            return .unknown
        default:
            return .unknown
        }
    }
    
    var text: String? {
        return button.text?.text
    }
    
    var iconName: String? {
        return button.icon?.name
    }
    
    var iconSize: Int32 {
        return button.iconSize
    }
    
    var iconGravity: IconGravity {
        switch button.iconGravity {
        case .start:
            return .start
        case .end:
            return .end
        default:
            return .start
        }
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: button.textScale)
    }
    
    var buttonWidth: GodToolsToolParser.Dimension {
        return button.width
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return MobileContentColor(color: button.backgroundColor)
    }
    
    func getColor() -> MobileContentColor? {
        return MobileContentColor(color: button.buttonColor)
    }
    
    func getTextColor() -> MobileContentColor? {
        if let textColor = button.text?.textColor {
            return MobileContentColor(color: textColor)
        }
        return nil
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return button.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
    
    func watchVisibility(rendererState: MobileContentMultiplatformState, visibilityChanged: @escaping ((_ visibility: MobileContentVisibility) -> Void)) -> MobileContentFlowWatcherType {
        
        let flowWatcher = button.watchVisibility(state: rendererState.state) { (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
            visibilityChanged(MobileContentVisibility(isInvisible: invisible.boolValue, isGone: gone.boolValue))
        }
        
        return MultiplatformFlowWatcher(flowWatcher: flowWatcher)
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentButton {
    
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
