//
//  LanguageSupportedText.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguageSupportedText: View {
    
    let languageName: String
    let isSupported: Bool
    
    var body: some View {
        
        HStack(alignment: .bottom, spacing: 4) {
            
            Text(languageName)
            Image(isSupported ? ImageCatalog.languageAvailableCheck.name: ImageCatalog.languageUnavailableX.name)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
        }
    }
}
