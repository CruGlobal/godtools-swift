//
//  ToolLanguageAvailableOfflineLanguageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolLanguageAvailableOfflineLanguageView: View {
    
    private let downloadedLanguage: DownloadedLanguageListItemDomainModel
    
    init(downloadedLanguage: DownloadedLanguageListItemDomainModel) {
        self.downloadedLanguage = downloadedLanguage
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 11) {
            
                Text(downloadedLanguage.languageNameInOwnLanguage)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.leading)
                
                Text(downloadedLanguage.languageNameInAppLanguage)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .foregroundColor(Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1))
                    .multilineTextAlignment(.leading)
            }
            .padding([.top, .bottom], 15)
            
            SeparatorView()
        }
    }
}
