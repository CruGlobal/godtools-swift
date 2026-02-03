//
//  AttachmentsBundleCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AttachmentsBundleCache {
    
    private let bundle: Bundle = Bundle.main
    
    init() {
        
    }
    
    func getBundledAttachment(attachment: AttachmentDataModel) -> Data? {
        
        return getBundledAttachment(resource: attachment.sha256)
    }
    
    func getBundledAttachment(resource: String) -> Data? {
                                
        guard let filePath = bundle.path(forResource: resource, ofType: nil) else {
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
