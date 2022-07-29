//
//  DetermineToolTranslationsToDownloadType.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

protocol DetermineToolTranslationsToDownloadType {
    
    func getResource() -> ResourceModel?
    func determineToolTranslationsToDownload() -> AnyPublisher<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError>
}
