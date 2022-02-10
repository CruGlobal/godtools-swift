//
//  ContentButtonModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol ContentButtonModelType: MobileContentRenderableModel {
    
    var events: [MultiplatformEventId] { get }
    var url: String? { get }
    var style: MobileContentButtonStyle? { get }
    var type: MobileContentButtonType { get }
    var text: String? { get }
    var iconName: String? { get }
    var iconSize: Int32 { get }
    var iconGravity: IconGravity { get }
    var textScale: MobileContentTextScale { get }
    var buttonWidth: GodToolsToolParser.Dimension { get }
    
    func getBackgroundColor() -> MobileContentColor?
    func getColor() -> MobileContentColor?
    func getTextColor() -> MobileContentColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
    func watchVisibility(rendererState: MobileContentMultiplatformState, visibilityChanged: @escaping ((_ visibility: MobileContentVisibility) -> Void)) -> MobileContentFlowWatcherType
}

extension ContentButtonModelType {
    var modelContentIsRenderable: Bool {
        return type != .unknown
    }
}
