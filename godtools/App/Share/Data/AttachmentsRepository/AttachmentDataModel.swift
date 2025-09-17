//
//  AttachmentDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class AttachmentDataModel: AttachmentDataModelInterface {
        
    let file: String
    let fileFilename: String
    let id: String
    let isZipped: Bool
    let resourceDataModel: ResourceDataModel?
    let sha256: String
    let storedAttachment: StoredAttachmentDataModel?
    let type: String
    
    init(interface: AttachmentDataModelInterface, storedAttachment: StoredAttachmentDataModel?) {
        
        file = interface.file
        fileFilename = interface.fileFilename
        id = interface.id
        isZipped = interface.isZipped
        resourceDataModel = interface.resourceDataModel
        sha256 = interface.sha256
        self.storedAttachment = storedAttachment
        type = interface.type
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
