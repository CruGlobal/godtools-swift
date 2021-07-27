//
//  ContentTextModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentTextModelType: MobileContentRenderableModel {
    
    var endImage: String? { get }
    var endImageSize: Int32 { get }
    var startImage: String? { get }
    var startImageSize: Int32 { get }
    var text: String? { get }
    var textStyle: String? { get }
    var textAlignment: MobileContentTextAlignment? { get }
    var textScale: MobileContentTextScale { get }
    
    func getTextColor() -> MobileContentColor?
}

extension ContentTextModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
