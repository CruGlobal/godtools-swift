//
//  ResourcesCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourcesCacheType {
    
    associatedtype Language = LanguageModelType
    associatedtype Resource = ResourceModelType
    
    func cacheResources(languages: [LanguageModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, complete: @escaping ((_ error: ResourcesCacheError?) -> Void))
    func getLanguages() -> [Language]
    func getResources() -> [Resource]
}
