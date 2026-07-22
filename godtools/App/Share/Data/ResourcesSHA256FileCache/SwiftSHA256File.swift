//
//  SwiftSHA256File.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftSHA256File = SwiftSHA256FileV1.SwiftSHA256File

@available(iOS 17.4, *)
enum SwiftSHA256FileV1 {
 
    @Model
    class SwiftSHA256File: IdentifiableSwiftDataObject {
                        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var sha256WithPathExtension: String = ""
        
        @Relationship(deleteRule: .noAction, inverse: \SwiftAttachment.sha256Files) var attachments: [SwiftAttachment] = Array<SwiftAttachment>()
        @Relationship(deleteRule: .noAction, inverse: \SwiftTranslation.sha256Files) var translations: [SwiftTranslation] = Array<SwiftTranslation>()
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftSHA256File {
    
    public static func idPredicate(id: String) -> Predicate<SwiftSHA256File> {
        return #Predicate<SwiftSHA256File> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftSHA256File> {
        return #Predicate<SwiftSHA256File> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: SHA256FileModel) {
        
        id = model.id
        sha256WithPathExtension = model.sha256WithPathExtension
        
        attachments = model.attachments.map {
            SwiftAttachment.createNewFrom(model: $0)
        }
        
        translations = model.translations.map {
            SwiftTranslation.createNewFrom(model: $0)
        }
    }
    
    static func createNewFrom(model: SHA256FileModel) -> RealmSHA256File {
        let object = RealmSHA256File()
        object.mapFrom(model: model)
        return object
    }
   
    func toModel() -> SHA256FileModel {
        return SHA256FileModel(
            id: id,
            sha256WithPathExtension: sha256WithPathExtension,
            attachments: attachments.map { $0.toModel() },
            translations: translations.map { $0.toModel() }
        )
    }
}
