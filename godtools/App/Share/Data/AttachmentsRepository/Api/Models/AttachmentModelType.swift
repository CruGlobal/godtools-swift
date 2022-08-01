//
//  AttachmentModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AttachmentModelType {
    
    associatedtype ResourceModel = ResourceModelType
    
    var file: String { get }
    var fileFilename: String { get }
    var id: String { get }
    var isZipped: Bool { get }
    var resourceId: String? { get }
    var sha256: String { get }
    var type: String { get }
    
    var resource: ResourceModel? { get }
}
