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
        
        // the interface strings should be translated into Spanish
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: ToolScreenShareQRCodeInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: ToolScreenShareQRCodeInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        var sinkCompleted: Bool = false
        

        appLanguagePublisher
            .flatMap { appLanguage in
                
                return getToolScreenShareQRCodeInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            }.sink { interfaceStrings in
                
                guard !sinkCompleted else {
                    return
                }
                
                sinkCount += 1
                
                if sinkCount == 1 {
                    
                    englishInterfaceStringsRef = interfaceStrings
                }
                else if sinkCount == 2 {
                    
                    spanishInterfaceStringsRef = interfaceStrings
                    
                    sinkCompleted = true
                        
                    return  // done
                }
                                                
                if sinkCount == 1 {
                    appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                }
            }
            .store(in: &cancellables)
        
        #expect(englishInterfaceStringsRef?.qrCodeDescription == "Scan this QR code to join along with me")
        #expect(spanishInterfaceStringsRef?.qrCodeDescription == "Escanea este código QR para unirte a mí")
        
        #expect(englishInterfaceStringsRef?.closeButtonTitle == "Close")
        #expect(spanishInterfaceStringsRef?.closeButtonTitle == "Cerrar")
    }
}

