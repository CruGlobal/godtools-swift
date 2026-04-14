//
//  GetToolScreenShareQRCodeStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetToolScreenShareQRCodeStringsUseCaseTests {
   
    private let qrCodeDescriptionKey = "toolScreenShare.qrCode.description"
    private let closeButtonTitleKey = "toolScreenShare.qrCode.closeButtonTitle"
    
    @Test("""
        Given: User is viewing tool screen share qr code.
        When: The app language is set.
        Then: The interface strings should be translated in the app language.
        """
    )
    func stringsAreTranslatedInAppLanguage() async {
                
        let getToolScreenShareQRCodeStringsUseCase = getToolScreenShareQRCodeStringsUseCase()
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishStringsRef: ToolScreenShareQRCodeStringsDomainModel?
        var spanishStringsRef: ToolScreenShareQRCodeStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getToolScreenShareQRCodeStringsUseCase
                        .execute(appLanguage: appLanguage)
                }.sink { strings in
                    
                    triggerCount += 1
                    
                    if triggerCount == 1 {
                        
                        englishStringsRef = strings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)

                    }
                    else if triggerCount == 2 {
                        
                        spanishStringsRef = strings
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }

        #expect(englishStringsRef?.qrCodeDescription == "Scan this QR code to join along with me")
        #expect(spanishStringsRef?.qrCodeDescription == "Escanea este código QR para unirte a mí")
        
        #expect(englishStringsRef?.closeButtonTitle == "Close")
        #expect(spanishStringsRef?.closeButtonTitle == "Cerrar")
    }
}

extension GetToolScreenShareQRCodeStringsUseCaseTests {
    
    private func getToolScreenShareQRCodeStringsUseCase() -> GetToolScreenShareQRCodeStringsUseCase {
        return GetToolScreenShareQRCodeStringsUseCase(
            localizationServices: getLocalizationServices()
        )
    }
    
    private func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                qrCodeDescriptionKey: "Scan this QR code to join along with me",
                closeButtonTitleKey: "Close"
            ],
            LanguageCodeDomainModel.spanish.value: [
                qrCodeDescriptionKey: "Escanea este código QR para unirte a mí",
                closeButtonTitleKey: "Cerrar"
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
}
