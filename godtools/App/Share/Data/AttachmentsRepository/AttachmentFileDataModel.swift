//
//  AttachmentFileDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct AttachmentFileDataModel {
    
    let attachment: AttachmentModel
    let data: Data
    let fileCacheLocation: FileCacheLocation
}
