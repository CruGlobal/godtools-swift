//
//  TestsGetDownloadToolProgressInterfaceStringsRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetDownloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepositoryInterface {
    
    let toolIsFavorited: Bool?
    let downloadToolMessage: String
    let favoriteThisToolForOfflineUseMessage: String
    
    init(toolIsFavorited: Bool?, downloadToolMessage: String, favoriteThisToolForOfflineUseMessage: String) {
        
        self.toolIsFavorited = toolIsFavorited
        self.downloadToolMessage = downloadToolMessage
        self.favoriteThisToolForOfflineUseMessage = favoriteThisToolForOfflineUseMessage
    }
    
    func getStringsPublisher(resource: ResourceModel?, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = DownloadToolProgressInterfaceStringsDomainModel(
            toolIsFavorited: toolIsFavorited,
            downloadingToolMessage: downloadToolMessage,
            favoriteThisToolForOfflineUseMessage: favoriteThisToolForOfflineUseMessage
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
