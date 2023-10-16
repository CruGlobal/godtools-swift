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
        
        let horizontalPadding: CGFloat = 20
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 16) {
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ImageCatalog.languageSettingsLogo.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                    
                    Spacer()
                }
                
                FixedVerticalSpacer(height: 10)
                
                Group {
                    Text("You have selected English as your app language. This will change the language of the whole GodTools app. Are you sure?")
                        .font(FontLibrary.sfProTextRegular.font(size: 18))
                        .foregroundColor(ColorPalette.gtGrey.color)
                                        
                    Text("Ha seleccinado Ingles como idioma de su aplicacion. Esto cambiara toda la aplicacion GodTools. Esta seguro?")
                        .font(FontLibrary.sfProTextRegular.font(size: 14))
                        .foregroundColor(ColorPalette.gtGrey.color)
                }
                .padding(.horizontal, 10)
                
                FixedVerticalSpacer(height: 20)
                
                let buttonSpacing: CGFloat = 12

                HStack(spacing: buttonSpacing) {
                    
                    let buttonWidth = (geometry.size.width - buttonSpacing - 2*horizontalPadding) / 2
                    
                    GTBlueButton(title: "Change language", fontSize: 15, width: buttonWidth, height: 48) {
                        
                    }
                    
                    GTWhiteButton(title: "Nevermind", fontSize: 15, width: buttonWidth, height: 48) {
                        
                    }
                    
                }
                
                Spacer()
                Spacer()
                
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}

struct ConfirmAppLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmAppLanguageView()
    }
}
