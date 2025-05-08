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
    
    @ObservedObject private var viewModel: OptInNotificationViewModel

    init(viewModel: OptInNotificationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        VStack {
            
            ImageCatalog.notificationGraphic
                .image
                .resizable()
                .scaledToFill()
                .padding(.horizontal, 15)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .padding(.horizontal, 5)
                        .foregroundColor(ColorPalette.gtBlue.color),
                    alignment: .bottom
                )
            
            Text(viewModel.title)
                .foregroundColor(ColorPalette.gtBlue.color)
                .font(FontLibrary.sfProTextRegular.font(size: 30))
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text(viewModel.body)
                .font(FontLibrary.sfProTextRegular.font(size: 17))
                .foregroundStyle(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Button(action: {
                
                viewModel.allowNotificationsTapped()

            }) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(ColorPalette.gtBlue.color)
            }
            .frame(height: 45)
            .overlay(
                Text(viewModel.allowNotificationsActionTitle)
                    .foregroundColor(.white)
            )

            Button(action: {
                
                viewModel.maybeLaterTapped()

            }) {
                Text(viewModel.maybeLaterActionTitle)
                    .foregroundColor(ColorPalette.gtBlue.color)
            }
            .frame(height: 40)
            .padding(.bottom, 60)
            
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                )
        )
        .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}

// MARK: - Preview

struct OptInNotificationView_Preview: PreviewProvider {

    static func getOptInNotificationViewModel() -> OptInNotificationViewModel {

        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

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
