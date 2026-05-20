//
//  GetToolScreenShareQRCodeStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolScreenShareQRCodeStringsUseCaseTests {
   
    private let qrCodeDescriptionKey = "toolScreenShare.qrCode.description"
    private let closeButtonTitleKey = "toolScreenShare.qrCode.closeButtonTitle"
    
    @Test("""
        Given: User is viewing tool screen share qr code.
        When: The app language is set to spanish.
        Then: The interface strings should be translated in the app language.
        """
    )
    func stringsAreTranslatedInAppLanguage() async {
                
        let getToolScreenShareQRCodeStringsUseCase = getToolScreenShareQRCodeStringsUseCase()
        
        let strings = getToolScreenShareQRCodeStringsUseCase
            .execute(appLanguage: LanguageCodeDomainModel.spanish.value)

        #expect(strings.qrCodeDescription == "Escanea este código QR para unirte a mí")
        #expect(strings.closeButtonTitle == "Cerrar")
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
