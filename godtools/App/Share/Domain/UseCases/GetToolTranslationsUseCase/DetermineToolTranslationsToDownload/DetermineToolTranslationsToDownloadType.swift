//
//  DetermineToolTranslationsToDownloadType.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol DetermineToolTranslationsToDownloadType {
        
    func getResource() -> ResourceModel?
    func determineToolTranslationsToDownload() -> Result<ToolTranslationsToDownload, DetermineToolTranslationsToDownloadError>
}
