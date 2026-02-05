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
    class SwiftAppLanguage: IdentifiableSwiftDataObject, AppLanguageDataModelInterface {
        
        var languageCode: String = ""
        var swiftLanguageDirection: SwiftAppLanguageDirection = SwiftAppLanguageDirection.leftToRight
        var languageId: String = ""
        var languageScriptCode: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
        
        func mapFrom(interface: AppLanguageDataModelInterface) {
            
            id = interface.languageId
            languageCode = interface.languageCode
            languageId = interface.languageId
            languageScriptCode = interface.languageScriptCode
            
            switch interface.languageDirection {
            case .leftToRight:
                swiftLanguageDirection = .leftToRight
            case .rightToLeft:
                swiftLanguageDirection = .rightToLeft
            }
        }
        
        static func createNewFrom(interface: AppLanguageDataModelInterface) -> SwiftAppLanguage {
            let object = SwiftAppLanguage()
            object.mapFrom(interface: interface)
            return object
        }
        
        var languageDirection: AppLanguageDataModel.Direction {
        
            switch swiftLanguageDirection {
            case .leftToRight:
                return .leftToRight
            case .rightToLeft:
                return .rightToLeft
            }
        }
    }
}
