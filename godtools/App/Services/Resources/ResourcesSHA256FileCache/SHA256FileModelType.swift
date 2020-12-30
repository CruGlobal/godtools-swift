//
//  SHA256FileModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol SHA256FileModelType {
    
    associatedtype Attachments = Sequence
    associatedtype Translations = Sequence
    
    var sha256WithPathExtension: String { get }
    var attachments: Attachments { get }
    var translations: Translations { get }
}

extension SHA256FileModelType {
    var location: SHA256FileLocation {
        return SHA256FileLocation(sha256WithPathExtension: sha256WithPathExtension)
    }
}
