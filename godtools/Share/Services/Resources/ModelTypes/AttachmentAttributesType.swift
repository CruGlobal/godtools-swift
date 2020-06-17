//
//  AttachmentAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AttachmentAttributesType: Codable {
    
    var file: String? { get }
    var isZipped: Bool { get }
    var sha256: String? { get }
    var fileFilename: String? { get }
}
