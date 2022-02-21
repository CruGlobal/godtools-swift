//
//  ContentTextModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol ContentTextModelType: MobileContentRenderableModel {
    
    var endImage: String? { get }
    var endImageSize: Int32 { get }
    var startImage: String? { get }
    var startImageSize: Int32 { get }
    var text: String? { get }
    var textAlignment: Text.Align { get }
    var textScale: Double { get }
    var minimumLines: Int32 { get }
    
    func getTextColor() -> UIColor
    func getTextStyles() -> [Text.Style]
}

extension ContentTextModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
