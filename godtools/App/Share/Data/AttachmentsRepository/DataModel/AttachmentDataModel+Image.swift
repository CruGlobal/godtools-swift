//
//  AttachmentDataModel+Image.swift
//  godtools
//
//  Created by Levi Eggert on 9/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

extension AttachmentDataModel {
    
    func getImageData() -> Data? {
        
        return storedAttachment?.data
    }
    
    func getImage() -> Image? {
        
        guard let uiImage = getUIImage() else {
           return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    func getUIImage() -> UIImage? {
        
        guard let data = storedAttachment?.data else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
