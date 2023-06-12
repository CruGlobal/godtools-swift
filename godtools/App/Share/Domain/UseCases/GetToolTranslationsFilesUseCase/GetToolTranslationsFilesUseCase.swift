//
//  GetToolTranslationsFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class GetToolTranslationsFilesUseCase {
        
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    private let getLanguageUseCase: GetLanguageUseCase
    
    private var getToolTranslationsCancellable: AnyCancellable?
    private var didInitiateDownloadStarted: Bool = false
        
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository, getLanguageUseCase: GetLanguageUseCase) {

        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.languagesRepository = languagesRepository
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getToolTranslationsFilesPublisher(filter: GetToolTranslationsFilesFilter, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, downloadStarted: (() -> Void)?) -> AnyPublisher<ToolTranslationsDomainModel, Error> {
                
        let manifestParserType: TranslationManifestParserType
        let includeRelatedFiles: Bool
        
        var translationsToDownload: [TranslationModel] = Array()
        
        switch filter {
        case .downloadManifestAndRelatedFilesForRenderer:
            manifestParserType = .renderer
            includeRelatedFiles = true
        case .downloadManifestForTipsCount:
            manifestParserType = .manifestOnly
            includeRelatedFiles = false
        }
        
        return determineToolTranslationsToDownload.determineToolTranslationsToDownload().publisher
            .catch({ (error: DetermineToolTranslationsToDownloadError) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> in
                
                self.initiateDownloadStarted(downloadStarted: downloadStarted)
                
                return self.resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
                    .flatMap({ (result: RealmResourcesCacheSyncResult) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> in
                        return determineToolTranslationsToDownload.determineToolTranslationsToDownload().publisher
                            .mapError { (error: DetermineToolTranslationsToDownloadError) in
                                return error as Error
                            }
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ result -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                   
                let translations: [TranslationModel] = result.translations
                
                translationsToDownload = result.translations
                
                return self.translationsRepository.getTranslationManifestsFromCache(translations: translations, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
                    .catch({ (error: Error) -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                        
                        self.initiateDownloadStarted(downloadStarted: downloadStarted)
                            
                        return self.translationsRepository.getTranslationManifestsFromRemote(translations: translations, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: true)
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ downloadedTranslations -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                
                var maintainTranslationDownloadOrder: [TranslationManifestFileDataModel] = Array()
                
                for translationToDownload in translationsToDownload {
                    
                    let translationManifest: TranslationManifestFileDataModel?
                    
                    if let downloadedTranslationManifest = downloadedTranslations.first(where: {$0.translation.id == translationToDownload.id}) {
                        translationManifest = downloadedTranslationManifest
                    }
                    else if let downloadedTranslationManifest = downloadedTranslations.first(where: {$0.translation.resource?.id == translationToDownload.resource?.id && $0.translation.language?.id == translationToDownload.language?.id}) {
                        translationManifest = downloadedTranslationManifest
                    }
                    else {
                        translationManifest = nil
                    }
                    
                    guard let translationManifest = translationManifest else {
                        continue
                    }
                    
                    maintainTranslationDownloadOrder.append(translationManifest)
                }
                
                return Just(maintainTranslationDownloadOrder).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .flatMap({ translationManifests -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                    
                let translations: [TranslationModel] = translationManifests.map({ $0.translation })
                
                return self.translationsRepository.getTranslationManifestsFromCache(translations: translations, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
                    .eraseToAnyPublisher()
            })
            .flatMap({ translationManifests -> AnyPublisher<ToolTranslationsDomainModel, Error> in
                
                guard let resource = translationManifests.first?.translation.resource else {
                    
                    let error = NSError.errorWithDescription(description: "Failed to get resource on translation model.")
                    
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                
                let languageManifets: [MobileContentRendererLanguageTranslationManifest] = translationManifests.compactMap({
                    
                    guard let language = $0.translation.language else {
                        return nil
                    }
                    
                    return MobileContentRendererLanguageTranslationManifest(
                        manifest: $0.manifest,
                        language: self.getLanguageUseCase.getLanguage(language: language),
                        translation: $0.translation
                    )
                })
                
                let domainModel = ToolTranslationsDomainModel(tool: resource, languageTranslationManifests: languageManifets)
                
                return Just(domainModel).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func initiateDownloadStarted(downloadStarted: (() -> Void)?) {
        
        guard !didInitiateDownloadStarted else {
            return
        }
        
        didInitiateDownloadStarted = true
        
        downloadStarted?()
    }
}


