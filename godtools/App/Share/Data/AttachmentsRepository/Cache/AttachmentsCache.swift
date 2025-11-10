//
//  AttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class AttachmentsCache: SwiftElseRealmPersistence<AttachmentDataModel, AttachmentCodable, RealmAttachment> {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmAttachmentDataModelMapping()
        )
    }
    
    @available(iOS 17.4, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<AttachmentDataModel, AttachmentCodable>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftAttachmentDataModelMapping()
        )
    }
}
