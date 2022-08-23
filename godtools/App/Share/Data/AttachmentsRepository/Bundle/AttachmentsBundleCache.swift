//
//  AttachmentsBundleCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class AttachmentsBundleCache {
    
    init() {
        
    }
    
    func getAttachmentData(attachment: AttachmentModel) -> Data? {
                                
        guard let filePath = Bundle.main.path(forResource: attachment.sha256, ofType: nil) else {
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
