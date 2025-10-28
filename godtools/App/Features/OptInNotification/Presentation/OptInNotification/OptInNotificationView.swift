//
//  OptInNotificationView.swift
//  godtools
//
//  Created by Jason Bennett on 3/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct OptInNotificationView: View {
    
    private let modalHorizontalPadding: CGFloat = 20
    private let buttonFontSize: CGFloat = 17
    private let buttonHeight: CGFloat = 50
    private let buttonHorizontalPadding: CGFloat = 20
    private let overlayTappedClosure: (() -> Void)?
    
    @ObservedObject private var viewModel: OptInNotificationViewModel
    
    @State private var modalIsHidden: Bool = true

    init(viewModel: OptInNotificationViewModel, overlayTappedClosure: (() -> Void)? = nil) {
       
        self.viewModel = viewModel
        self.overlayTappedClosure = overlayTappedClosure
    }

    var body: some View {
        
        GTModalView(content: { geometry in
            
            let contentWidth: CGFloat = geometry.size.width - (modalHorizontalPadding * 2)
            
            VStack(alignment: .center, spacing: 0) {
                
                ImageCatalog.notificationGraphic
                    .image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 263, height: 140)
                    .padding(.horizontal, 15)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .padding(.horizontal, 5)
                            .foregroundColor(ColorPalette.gtBlue.color),
                        alignment: .bottom
                    )
                
                Text(viewModel.title)
                    .frame(width: contentWidth)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .font(FontLibrary.sfProTextBold.font(size: 30))
                    .padding(.top, 20)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)

                Text(viewModel.body)
                    .frame(width: contentWidth)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .foregroundStyle(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                    .padding(.top, 13)
                
                let buttonWidth: CGFloat = geometry.size.width - (modalHorizontalPadding * 2) - (buttonHorizontalPadding * 2)
                
                GTBlueButton(
                    title: viewModel.notificationsActionTitle,
                    fontSize: buttonFontSize,
                    width: buttonWidth,
                    height: buttonHeight,
                    action: {
                        
                        modalIsHidden = true
                        
                        viewModel.allowNotificationsTapped()
                    }
                )
                .padding(.top, 18)
                
                GTWhiteButton(
                    title: viewModel.maybeLaterActionTitle,
                    fontSize: buttonFontSize,
                    width: buttonWidth,
                    height: buttonHeight,
                    action: {
                        
                        modalIsHidden = true

                        viewModel.maybeLaterTapped()
                    }
                )
                .padding(.top, 12)
                
                FixedVerticalSpacer(height: 30)
            }
            
        }, isHidden: $modalIsHidden, overlayTappedClosure: {
            
            overlayTappedClosure?()
            
        }, backgroundHorizontalPadding: modalHorizontalPadding, strokeColor: ColorPalette.gtBlue.color, strokeLineWidth: 8)
    }
}

// MARK: - Preview

struct OptInNotificationView_Preview: PreviewProvider {

    static func getOptInNotificationViewModel() -> OptInNotificationViewModel {

        let appDiContainer = AppDiContainer.createUITestsDiContainer()

        let viewModel = OptInNotificationViewModel(
            flowDelegate: MockFlowDelegate(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewOptInNotificationUseCase: appDiContainer.feature.optInNotification.domainLayer.getViewOptInNotificationUseCase(),
            notificationPromptType: .allow
        )

        return viewModel
    }

    static var previews: some View {

        OptInNotificationView(
            viewModel: OptInNotificationView_Preview.getOptInNotificationViewModel()
        )
    }
}
