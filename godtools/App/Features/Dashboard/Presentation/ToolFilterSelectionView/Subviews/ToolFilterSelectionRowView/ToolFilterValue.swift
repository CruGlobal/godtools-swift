//
//  ToolFilterValue.swift
//  godtools
//
//  Created by Rachael Skeath on 9/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum ToolFilterValue {
    case category(categoryModel: ToolCategoryDomainModel)
    case language(languageModel: LanguageFilterDomainModel)
}

extension ToolFilterValue: Equatable {
    
    static func == (lhs: ToolFilterValue, rhs: ToolFilterValue) -> Bool {
        
        switch lhs {
            
        case .category(let lhsCategoryModel):
            
            if case let .category(rhsCategoryModel) = rhs {
                
                return lhsCategoryModel.id == rhsCategoryModel.id
            }
            
        case .language(let lhsLanguageModel):
            
            if case let .language(rhsLanguageModel) = rhs {
                
                return lhsLanguageModel.id == rhsLanguageModel.id
            }
        }
        
        return false
    }
}
