//
//  DownloadedTranslationDataModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol DownloadedTranslationDataModelType {
    
    var manifestAndRelatedFilesPersistedToDevice: Bool { get }
    var translationId: String { get }
}
