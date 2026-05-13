//
//  GetShareablesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared

final class GetShareablesUseCase {
    
    private let translationsRepository: TranslationsRepository
    
    init(translationsRepository: TranslationsRepository) {
        
        self.translationsRepository = translationsRepository
    }
    
    func execute(toolId: String, toolLanguageId: String) -> AnyPublisher<[ShareableDomainModel], Error> {
        
        return AnyPublisher() {
            try await self.asyncExecute(toolId: toolId, toolLanguageId: toolLanguageId)
        }
        .eraseToAnyPublisher()
    }
    
    private func asyncExecute(toolId: String, toolLanguageId: String) async throws -> [ShareableDomainModel] {
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: toolId, languageId: toolLanguageId) else {
            return Array()
        }
        
        let dataModel: TranslationManifestFileDataModel = try await translationsRepository.getTranslationManifestFromCacheElseRemote(
            translation: translation,
            manifestParserType: .manifestOnly,
            requestPriority: .medium,
            includeRelatedFiles: true,
            shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
        )
        
        let manifestShareables: [Shareable] = dataModel.manifest.shareables
            .sorted(by: { $0.order < $1.order })
        
        let shareables: [ShareableDomainModel] = manifestShareables.compactMap {
            
            guard let shareableImage = $0 as? ShareableImage, let dataModelId = shareableImage.id else {
                return nil
            }
            
            return ShareableDomainModel(
                dataModelId: dataModelId,
                imageName: shareableImage.resource?.localName ?? "",
                title: shareableImage.description_?.text ?? ""
            )
        }
        
        return shareables
    }
}
