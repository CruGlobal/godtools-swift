//
//  DownloadToolProgressStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadToolProgressStringsDomainModel: Sendable {
    
    let downloadMessage: String
    
    static var emptyValue: DownloadToolProgressStringsDomainModel {
        return DownloadToolProgressStringsDomainModel(downloadMessage: "")
    }
}
