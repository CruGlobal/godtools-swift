//
//  ConfirmAppLanguageView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ConfirmAppLanguageView: View {
    var body: some View {
        
        VStack(spacing: 16) {
            
            ImageCatalog.languageSettingsLogo.image
                .resizable()
                .scaledToFill()
                .frame(width: 54, height: 54)
            
            VStack(spacing: 30) {
                
                Text("You have selected English as your app language. This will change the language of the whole GodTools app. Are you sure?")
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                Text("Ha seleccinado Ingles como idioma de su aplicacion. Esto cambiara toda la aplicacion GodTools. Esta seguro?")
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
            }
//            .padding(.horizontal, 30)
            
            HStack {
                GTBlueButton(title: "Change language", fontSize: 15, width: 145, height: 48) {
                    
                }
                
                GTWhiteButton(title: "Nevermind", fontSize: 15, width: 145, height: 48) {
                    
                }
            }
        }
    }
}

struct ConfirmAppLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmAppLanguageView()
    }
}
