//
//  SwiftAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftAppLanguage = SwiftAppLanguageV1.SwiftAppLanguage

@available(iOS 17.4, *)
enum SwiftAppLanguageV1 {
 
    @Model
    class SwiftAppLanguage: IdentifiableSwiftDataObject {
        
        var languageCode: String = ""
        var swiftLanguageDirection: SwiftAppLanguageDirection = SwiftAppLanguageDirection.leftToRight
        var languageId: String = ""
        var languageScriptCode: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
        
        func mapFrom(model: AppLanguageDataModel) {
            
            id = model.languageId
            languageCode = model.languageCode
            languageId = model.languageId
            languageScriptCode = model.languageScriptCode
            
            switch model.languageDirection {
            case .leftToRight:
                swiftLanguageDirection = .leftToRight
            case .rightToLeft:
                swiftLanguageDirection = .rightToLeft
            }
        }
        
        static func createNewFrom(model: AppLanguageDataModel) -> SwiftAppLanguage {
            let object = SwiftAppLanguage()
            object.mapFrom(model: model)
            return object
        }
    }
}

@available(iOS 17.4, *)
extension SwiftAppLanguage {
    
    var languageDirection: AppLanguageDataModel.Direction {
    
        switch swiftLanguageDirection {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}

@available(iOS 17.4, *)
extension SwiftAppLanguage {
    
    func toModel() -> AppLanguageDataModel {
        
        return AppLanguageDataModel(
            languageCode: languageCode,
            languageDirection: languageDirection,
            languageScriptCode: languageScriptCode
        )
    }
}
