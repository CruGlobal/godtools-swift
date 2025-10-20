//
//  AttachmentsBundleCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AttachmentsBundleCache {
    
    init() {
        
    }
    
    func getAttachmentData(attachment: AttachmentDataModel) -> Data? {
        
        return getAttachmentData(resource: attachment.sha256)
    }
    
    func getAttachmentData(resource: String) -> Data? {
                                
        guard let filePath = Bundle.main.path(forResource: resource, ofType: nil) else {
            return nil
        }
        
        let url: URL = URL(fileURLWithPath: filePath)
        
        do {
            let data: Data = try Data(contentsOf: url, options: [])
            return data
        }
        catch {
            return nil
        }
    }
}
