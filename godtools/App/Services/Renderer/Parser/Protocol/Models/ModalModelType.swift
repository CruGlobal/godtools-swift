//
//  ModalModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ModalModelType: MobileContentRenderableModel {
    
    var dismissListeners: [String] { get }
    var listeners: [String] { get }
}

extension ModalModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
