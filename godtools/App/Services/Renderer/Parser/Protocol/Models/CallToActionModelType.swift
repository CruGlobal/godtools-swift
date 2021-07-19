//
//  CallToActionModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol CallToActionModelType: MobileContentRenderableModel {
    
    var controlColor: String? { get }
    var text: String? { get }
    
    func getTextColor() -> MobileContentRGBAColor?
    func getControlColor() -> MobileContentRGBAColor?
}

extension CallToActionModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
