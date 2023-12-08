//
//  AppLanguageItemView.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AppLanguageItemView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let appLanguage: AppLanguageListItemDomainModel
    private let tappedClosure: (() -> Void)?
    
    init(appLanguage: AppLanguageListItemDomainModel, tappedClosure: (() -> Void)?) {
        
        self.appLanguage = appLanguage
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        Button {
            tappedClosure?()
            
        } label: {
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(spacing: 10) {
                        
                        Text(appLanguage.languageNameTranslatedInOwnLanguage)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(ColorPalette.gtGrey.color)
                        
                        Text(appLanguage.languageNameTranslatedInCurrentAppLanguage)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(AppLanguageItemView.lightGrey)
                    }
                }
                .padding(.vertical, 3)
                
                Spacer()
            }
        }
    }
}
