//
//  DetermineToolTranslationsToDownloadInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

protocol DetermineToolTranslationsToDownloadInterface {
    
    @MainActor func getResource() -> ResourceDataModel?
    @MainActor func determineToolTranslationsToDownloadPublisher() -> AnyPublisher<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError>
}
