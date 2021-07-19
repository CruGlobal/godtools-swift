//
//  CallToActionModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol CallToActionModelType: MobileContentRenderableModel {
    
    var text: String? { get }
    
    func getTextColor() -> UIColor?
    func getControlColor() -> UIColor?
}

extension CallToActionModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
