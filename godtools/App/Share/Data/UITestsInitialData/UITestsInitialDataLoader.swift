//
//  UITestsInitialDataLoader.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import SwiftData

final class UITestsInitialDataLoader {
    
    private static let tmtsTractId: String = "ui_test_resource_1"
    private static let fslTractId: String = "ui_test_resource_2"
    private static let tmtsEnTranslation: String = "tmts_en_translation"
    private static let tmtsManifest: String = "tmts_manifest"
    private static let fslEnTranslation: String = "fsl_en_translation"
    private static let fslManifest: String = "fsl_manifest"
    
    private let resourcesCacheSync: ResourcesCacheSyncInterface
    private let languagesPersistence: any Persistence<LanguageDataModel, LanguageCodable>
    private let favoritedResourcesPersistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>
    private let resourcesFileCache: ResourcesSHA256FileCacheInterface
    private let appLanguagesPersistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
    
    init(
        resourcesCacheSync: ResourcesCacheSyncInterface,
        languagesPersistence: any Persistence<LanguageDataModel, LanguageCodable>,
        favoritedResourcesPersistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>,
        resourcesFileCache: ResourcesSHA256FileCacheInterface,
        appLanguagesPersistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
    ) {
        
        self.resourcesCacheSync = resourcesCacheSync
        self.languagesPersistence = languagesPersistence
        self.favoritedResourcesPersistence = favoritedResourcesPersistence
        self.resourcesFileCache = resourcesFileCache
        self.appLanguagesPersistence = appLanguagesPersistence
    }
    
    func loadData() async throws {
        
        try await appLanguagesPersistence.writeObjects(externalObjects: Self.getAppLanguages())
        
        _ = try await languagesPersistence.writeObjects(
            externalObjects: [Self.getEnglishLanguage()],
            writeOption: .deleteObjectsNotInExternal,
            getOption: nil
        )
        
        _ = try await resourcesCacheSync.syncResources(
            resourcesPlusLatestTranslationsAndAttachments: Self.getResourcesPlusLatestTranslationsAndAttachments(),
            shouldRemoveDataThatNoLongerExists: true
        )
                    
        try await loadTranslationManifests()
        
        try await favoritedResourcesPersistence.writeObjects(externalObjects: Self.getFavoritedResources())
    }
    
    private func loadTranslationManifests() async throws {
        
        guard let tmtsManifestData = PreviewAssets.tmtsManifest.data, let tmtsTractData = PreviewAssets.tmtsTract.data else {
            throw NSError.errorWithDescription(description: "UITestsInitialDataLoader: Failed to get tmts manifest from preview assets.")
        }
        
        guard let fslManifestData = PreviewAssets.fslManifest.data, let fslTractData = PreviewAssets.fslTract.data else {
            throw NSError.errorWithDescription(description: "UITestsInitialDataLoader: Failed to get fsl manifest from preview assets.")
        }
                
        _ = try await resourcesFileCache.storeTranslationFile(
            translationId: Self.tmtsEnTranslation,
            fileName: Self.tmtsManifest,
            fileData: tmtsManifestData
        )
        
        _ =  try await resourcesFileCache.storeTranslationZipFile(
            translationId: Self.tmtsEnTranslation,
            zipFileData: tmtsTractData
        )
        
        _ = try await resourcesFileCache.storeTranslationFile(
            translationId: Self.fslEnTranslation,
            fileName: Self.fslManifest,
            fileData: fslManifestData
        )
        
        _ =  try await resourcesFileCache.storeTranslationZipFile(
            translationId: Self.fslEnTranslation,
            zipFileData: fslTractData
        )
    }
    
    private static func getResourcesPlusLatestTranslationsAndAttachments() -> ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        
        return ResourcesPlusLatestTranslationsAndAttachmentsCodable(
            resources: [getTeachMeToShareTool(), getFourSpiritualLawsTool()],
            attachments: [],
            translations: [getTMTSTranslation(), getFSLTranslation()]
        )
    }
    
    private static func getTeachMeToShareTool() -> ResourceCodable {
        
        return ResourceCodable(
            id: tmtsTractId,
            abbreviation: "teachmetoshare",
            attrCategory: "training",
            attrDefaultLocale: "en",
            attrSpotlight: true,
            isHidden: false,
            latestTranslationIds: [tmtsEnTranslation],
            name: AccessibilityStrings.Button.ToolName.teachMeToShare.rawValue,
            resourceDescription: "Training tips on how to share your faith.",
            resourceType: ResourceType.tract.rawValue,
            totalViews: 615670
        )
    }
    
    private static func getFourSpiritualLawsTool() -> ResourceCodable {
        
        return ResourceCodable(
            id: fslTractId,
            abbreviation: "fourlaws",
            attrCategory: "gospel",
            attrDefaultLocale: "en",
            attrSpotlight: false,
            isHidden: false,
            latestTranslationIds: [fslEnTranslation],
            name: AccessibilityStrings.Button.ToolName.fourSpiritualLaws.rawValue,
            resourceDescription: "Classic gospel presentation of God's invitation to those who don't yet know him. \n\nConversation starter: I have a summary of the Bible's message using four simple ideas. May I share it with you?\n\nAll Bible references are from the New American Standard Bible unless otherwise stated.",
            resourceType: ResourceType.tract.rawValue,
            totalViews: 2533146
        )
    }
    
    private static func getTMTSTranslation() -> TranslationCodable {
        
        return TranslationCodable(
            id: tmtsEnTranslation,
            isPublished: true,
            language: getEnglishLanguage(),
            manifestName: tmtsManifest,
            resource: getTeachMeToShareTool(),
            translatedName: AccessibilityStrings.Button.ToolName.teachMeToShare.rawValue,
            version: 1
        )
    }
    
    private static func getFSLTranslation() -> TranslationCodable {
            
        return TranslationCodable(
            id: fslEnTranslation,
            isPublished: true,
            language: getEnglishLanguage(),
            manifestName: fslManifest,
            resource: getFourSpiritualLawsTool(),
            translatedName: AccessibilityStrings.Button.ToolName.fourSpiritualLaws.rawValue,
            version: 1
        )
    }
    
    private static func getEnglishLanguage() -> LanguageCodable {
        
        return LanguageCodable(
            id: "ui_test_language_1",
            code: "en",
            directionString: "ltr",
            name: "English"
        )
    }
    
    private static func getFavoritedResources() -> [FavoritedResourceDataModel] {
        
        return [
            FavoritedResourceDataModel(id: fslTractId, createdAt: Date(), position: 0)
        ]
    }
    
    private static func getAppLanguages() -> [AppLanguageCodable] {
        
        return [
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
    }
}
