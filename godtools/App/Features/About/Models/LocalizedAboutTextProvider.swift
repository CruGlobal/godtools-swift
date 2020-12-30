//
//  LocalizedAboutTextProvider.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizedAboutTextProvider: AboutTextProviderType {
    
    let aboutTexts: [AboutTextModel]
    
    required init(localizationServices: LocalizationServices) {
        
        aboutTexts = [
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_1")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_2")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_3")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_4")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_5")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_6")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_7")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_8")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_9")),
            AboutTextModel(text: localizationServices.stringForMainBundle(key: "general_about_10"))
        ]
    }
}
