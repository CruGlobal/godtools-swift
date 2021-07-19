//
//  ContentInputModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentInputModelType: MobileContentRenderableModel {
    
    var name: String? { get }
    var required: String? { get }
    var type: String? { get }
    var value: String? { get }
    var inputType: MobileContentInputNodeType { get }
    var isRequired: Bool { get }
    var text: String? { get }
    var placeholderText: String? { get }
}

extension ContentInputModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
