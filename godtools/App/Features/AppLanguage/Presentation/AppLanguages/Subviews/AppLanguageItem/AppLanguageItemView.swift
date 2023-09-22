//
//  AppLanguageItemView.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AppLanguageItemView: View {
    
    private let appLanguage: AppLanguageDomainModel
    private let tappedClosure: (() -> Void)?
    
    init(appLanguage: AppLanguageDomainModel, tappedClosure: (() -> Void)?) {
        
        self.appLanguage = appLanguage
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            FixedVerticalSpacer(height: 24)
            
            Text("Language Code: \(appLanguage.languageCode)")
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .foregroundColor(Color.black)
            
            FixedVerticalSpacer(height: 24)
            
            SeparatorView()
        }
        .contentShape(Rectangle()) // This fixes tap area not taking entire card into account.  Noticeable in iOS 14.
        .onTapGesture {
            tappedClosure?()
        }
    }
}
