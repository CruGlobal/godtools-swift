//
//  GetResourcesAttachments.swift
//  godtools
//
//  Created by Levi Eggert on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetResourcesAttachments {
    
    static func getResourceAttachments(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<[AttachmentModel], Never> {
        
        let attachmentIds: [String] = resourcesPlusLatestTranslationsAndAttachments.resources.map({$0.attrBanner})
                
        let attachments: [AttachmentModel] = resourcesPlusLatestTranslationsAndAttachments.attachments.filter({attachmentIds.contains($0.id)})
        
        return Just(attachments)
            .eraseToAnyPublisher()
    }
}
