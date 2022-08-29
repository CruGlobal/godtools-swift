//
//  AttachmentModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AttachmentModelType {
        
    var file: String { get }
    var fileFilename: String { get }
    var id: String { get }
    var isZipped: Bool { get }
    var sha256: String { get }
    var type: String { get }

    func getResource() -> ResourceModel?
}
