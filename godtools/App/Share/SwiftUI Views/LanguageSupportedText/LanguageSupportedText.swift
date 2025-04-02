//
//  LanguageSupportedText.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguageSupportedText: View {
    
    private let greenTextColor = Color.getColorWithRGB(red: 88, green: 170, blue: 66, opacity: 1)
    private let redTextColor = Color(.sRGB, red: 229 / 255, green: 91 / 255, blue: 54 / 255, opacity: 1.0)
    
    let languageName: String
    let isSupported: Bool
    
    var body: some View {
        
        HStack(alignment: .bottom, spacing: 4) {
            
            Text(languageName)
            Image(isSupported ? ImageCatalog.languageAvailableCheck.name : ImageCatalog.languageUnavailableX.name)
                .renderingMode(.template)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
        }
        .foregroundColor(isSupported ? greenTextColor : redTextColor)
    }
}
