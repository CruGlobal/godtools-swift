//
//  DeleteAccountView.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DeleteAccountView: View {
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 45, leading: 35, bottom: 35, trailing: 35)
    private let backgroundColor: Color
    private let buttonFont: Font = FontLibrary.sfProTextRegular.font(size: 16)
    private let buttonHeight: CGFloat = 50
    private let buttonCornerRadius: CGFloat = 6
    
    @ObservedObject private var viewModel: DeleteAccountViewModel
    
    init(viewModel: DeleteAccountViewModel, backgroundColor: Color) {
        
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                FixedVerticalSpacer(height: contentInsets.top)
                
                ImageCatalog.loginBackground.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 7) {
                    
                    Text(viewModel.title)
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 30))
                    
                    Text(viewModel.subtitle)
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 18))
                }
                .padding(EdgeInsets(top: 0, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    let buttonWidth: CGFloat = geometry.size.width - contentInsets.leading - contentInsets.trailing
                    
                    GTWhiteButton(title: viewModel.confirmButtonTitle, font: buttonFont, width: buttonWidth, height: buttonHeight, cornerRadius: buttonCornerRadius) {
                        
                        viewModel.deleteAccountTapped()
                    }
                    
                    GTBlueButton(title: viewModel.cancelButtonTitle, font: buttonFont, width: buttonWidth, height: buttonHeight, cornerRadius: buttonCornerRadius) {
                        
                        viewModel.cancelTapped()
                    }
                }
                .padding(EdgeInsets(top: 35, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                
                FixedVerticalSpacer(height: contentInsets.bottom)
            }
        }
        .background(Color.white)
    }
}

struct DeleteAccountView_Preview: PreviewProvider {
    
    static var previews: some View {
                
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = DeleteAccountViewModel(
            flowDelegate: MockFlowDelegate(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        return DeleteAccountView(viewModel: viewModel, backgroundColor: Color.white)
    }
}
