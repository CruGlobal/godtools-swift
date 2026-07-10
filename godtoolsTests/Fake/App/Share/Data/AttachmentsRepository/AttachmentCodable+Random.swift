//
//  AttachmentCodable+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension AttachmentCodable {

    static func random(
        id: String = UUID().uuidString,
        file: String = String.random(),
        fileFilename: String = String.random(),
        isZipped: Bool = Bool.random(),
        sha256: String = String.random(),
        type: String = String.random(),
        resource: ResourceCodable? = nil
    ) -> AttachmentCodable {

        return AttachmentCodable(
            id: id,
            file: file,
            fileFilename: fileFilename,
            isZipped: isZipped,
            sha256: sha256,
            type: type,
            resource: resource
        )
    }
}
