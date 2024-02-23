//
//  GetShareablesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class GetShareablesRepository: GetShareablesRepositoryInterface {
    
    private let translationsRepository: TranslationsRepository
    
    init(translationsRepository: TranslationsRepository) {
        
        self.translationsRepository = translationsRepository
    }
    
    func getShareablesPublisher(toolId: String, toolLanguageId: String) -> AnyPublisher<[ShareableDomainModel], Never> {
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: toolId, languageId: toolLanguageId) else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        return translationsRepository.getTranslationManifestFromCacheElseRemote(
            translation: translation,
            manifestParserType: .manifestOnly,
            includeRelatedFiles: true,
            shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
        )
        .map { (dataModel: TranslationManifestFileDataModel) in
                        
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
        .catch { _ in
            return Just([])
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
