//
//  RealmAttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmAttachmentsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getAttachment(id: String) -> AttachmentModel? {
        
        guard let realmAttachment = realmDatabase.mainThreadRealm.object(ofType: RealmAttachment.self, forPrimaryKey: id) else {
            return nil
        }
        
        return AttachmentModel(realmAttachment: realmAttachment)
    }
    
    func storeAttachments(attachments: [AttachmentModel], deletesNonExisting: Bool) -> AnyPublisher<[AttachmentModel], Error> {
        
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var attachmentsToRemove: [RealmAttachment] = Array(realm.objects(RealmAttachment.self))
                var writeError: Error?
                
                do {
                    
                    try realm.write {
                        
                        for attachment in attachments {
                            
                            if let index = attachmentsToRemove.firstIndex(where: {$0.id == attachment.id}) {
                                attachmentsToRemove.remove(at: index)
                            }
   
                            if let existingAttachment = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachment.id) {
                                
                                existingAttachment.mapFrom(model: attachment, shouldIgnoreMappingPrimaryKey: true)
                            }
                            else {
                                
                                let newAttachment: RealmAttachment = RealmAttachment()
                                newAttachment.mapFrom(model: attachment, shouldIgnoreMappingPrimaryKey: false)
                                realm.add(newAttachment)
                            }
                        }
                                
                        if deletesNonExisting {
                            realm.delete(attachmentsToRemove)
                        }
                        
                        writeError = nil
                    }
                }
                catch let error {
                    
                    writeError = error
                }
                
                if let writeError = writeError {
                    
                    promise(.failure(writeError))
                }
                else {
                    
                    promise(.success(attachments))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
