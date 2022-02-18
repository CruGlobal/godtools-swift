//
//  ContentTextModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ContentTextModelType: MobileContentRenderableModel {
    
    var endImage: String? { get }
    var endImageSize: Int32 { get }
    var startImage: String? { get }
    var startImageSize: Int32 { get }
    var text: String? { get }
    var textAlignment: MobileContentTextAlignment? { get }
    var textScale: MobileContentTextScale { get }
    var minimumLines: Int32 { get }
    
    func getTextColor() -> UIColor
    func getTextStyles() -> [MobileContentTextStyle]
}

extension ContentTextModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
