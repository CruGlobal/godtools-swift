//
//  GetToolScreenShareQRCodeInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetToolScreenShareQRCodeInterfaceStringsRepositoryTests {
   
    @Test("When the app language is switched from English to Spanish, the interface strings should be translated into Spanish.")
    func interfaceStringsTranslateWhenAppLanguageChanges() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let qrCodeDescriptionKey = "toolScreenShare.qrCode.description"
        let closeButtonTitleKey = "toolScreenShare.qrCode.closeButtonTitle"
        
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
        
        let getToolScreenShareQRCodeInterfaceStringsRepository = GetToolScreenShareQRCodeInterfaceStringsRepository(
            localizationServices: MockLocalizationServices(
                localizableStrings: localizableStrings
            )
        )
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: ToolScreenShareQRCodeInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: ToolScreenShareQRCodeInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getToolScreenShareQRCodeInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage)
                        .eraseToAnyPublisher()
                }.sink { interfaceStrings in
                    
                    sinkCount += 1
                    confirmation()
                    
                    if sinkCount == 1 {
                        
                        englishInterfaceStringsRef = interfaceStrings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)

                    }
                    else if sinkCount == 2 {
                        
                        spanishInterfaceStringsRef = interfaceStrings
                    }
                }
                .store(in: &cancellables)
        }

        
        #expect(englishInterfaceStringsRef?.qrCodeDescription == "Scan this QR code to join along with me")
        #expect(spanishInterfaceStringsRef?.qrCodeDescription == "Escanea este código QR para unirte a mí")
        
        #expect(englishInterfaceStringsRef?.closeButtonTitle == "Close")
        #expect(spanishInterfaceStringsRef?.closeButtonTitle == "Cerrar")
    }
}

