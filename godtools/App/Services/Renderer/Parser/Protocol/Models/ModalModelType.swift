//
//  ModalModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ModalModelType: MobileContentRenderableModel {
    
    var dismissListeners: [MultiplatformEventId] { get }
    var listeners: [MultiplatformEventId] { get }
}

extension ModalModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
