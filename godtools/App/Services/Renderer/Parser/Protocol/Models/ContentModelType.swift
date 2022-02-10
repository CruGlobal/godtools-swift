//
//  ContentModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentModelType: MobileContentRenderableModel {
    
    var contentInsets: UIEdgeInsets { get }
    var itemSpacing: CGFloat { get }
    var scrollIsEnabled: Bool { get }
}

extension ContentModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
