//
//  MultiplatformContentInput.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentInput: ContentInputModelType {
    
    private let input: Input
    
    required init(input: Input) {
        
        self.input = input
    }
    
    var name: String? {
        return input.name
    }
    
    var value: String? {
        return input.value
    }
    
    var type: MobileContentInputType {
        
        switch input.type {
        case .email:
            return .email
        case .hidden:
            return .hidden
        case .phone:
            return .phone
        case .text:
            return .text
        default:
            assertionFailure("Returning unsupported type.  Check that we are providing values for all input.type enum values.")
            return .text
        }
    }
    
    var isRequired: Bool {
        return !input.isIgnored
    }
    
    var text: String? {
        return input.label?.text
    }
    
    var placeholderText: String? {
        return input.placeholder?.text
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentInput {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
