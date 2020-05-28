//
//  AttachmentType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AttachmentType: Codable {
    
    associatedtype Attributes: AttachmentAttributesType
    
    var id: String { get }
    var type: String { get }
    var attributes: Attributes? { get }
}
