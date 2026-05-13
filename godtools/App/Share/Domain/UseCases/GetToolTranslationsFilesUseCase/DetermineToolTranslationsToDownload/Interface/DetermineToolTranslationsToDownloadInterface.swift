//
//  DetermineToolTranslationsToDownloadInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol DetermineToolTranslationsToDownloadInterface {
    
    func getResource() -> ResourceDataModel?
    func determineToolTranslationsToDownload() async throws(DetermineToolTranslationsToDownloadError) -> ToolTranslationsToDownload
}
