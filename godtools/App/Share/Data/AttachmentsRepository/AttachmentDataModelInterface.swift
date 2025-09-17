//
//  AttachmentDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol AttachmentDataModelInterface {
    
    var file: String { get }
    var fileFilename: String { get }
    var id: String { get }
    var isZipped: Bool { get }
    var resourceDataModel: ResourceDataModel? { get }
    var sha256: String { get }
    var type: String { get }
}
