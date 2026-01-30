//
//  AppLanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

class AppLanguagesApi {
    
    init() {
        
    }
    
    private func getAppLanguages() -> [AppLanguageCodable] {
        
        let allAppLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "af", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "am", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "bn", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "de", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "fr", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ha", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "hi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "id", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ja", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ko", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ne", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "om", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "pt", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ro", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ru", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "sw", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ur", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "vi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant")
        ]
        
        return allAppLanguages
    }
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageCodable], Error> {
        
        return Just(getAppLanguages())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension AppLanguagesApi: ExternalDataFetchInterface {
    
    func getObject(id: String, context: RequestOperationFetchContext) async throws -> [AppLanguageCodable] {
        return try await emptyResponse()
    }
    
    func getObjects(context: RequestOperationFetchContext) async throws -> [AppLanguageCodable] {
        return getAppLanguages()
    }
    
    @available(*, deprecated) func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[AppLanguageCodable], Error> {
        return emptyResponsePublisher()
            .eraseToAnyPublisher()
    }
    
    @available(*, deprecated) func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[AppLanguageCodable], Error> {
        return getAppLanguagesPublisher()
            .eraseToAnyPublisher()
    }
}
