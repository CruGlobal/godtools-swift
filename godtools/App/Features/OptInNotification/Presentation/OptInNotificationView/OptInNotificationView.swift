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
            Image("notification_graphic").resizable()
                .scaledToFit()
                .padding(
                    EdgeInsets(
                        top: 5,
                        leading: 5,
                        bottom: 0,
                        trailing: 5
                    )
                ).overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(
                            Color(
                                uiColor: ColorPalette.gtBlue
                                    .uiColor
                            )
                        ),
                    alignment: .bottom
                )
            Text(viewModel.title)
                .foregroundColor(
                    Color(uiColor: ColorPalette.gtBlue.uiColor)
                ).font(
                    FontLibrary.sfProTextRegular.font(size: 30)
                )
                .fontWeight(.bold)
                .padding(
                    .vertical,
                    10
                ).minimumScaleFactor(0.5).lineLimit(1)

            Text(
                viewModel.body
            ).font(FontLibrary.sfProTextRegular.font(size: 18))
                .foregroundStyle(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.center).padding(
                    .bottom,
                    12
                )

            Button(action: {
                viewModel.allowNotificationsTapped()

            }) {
                RoundedRectangle(cornerRadius: 5).fill(
                    Color(uiColor: ColorPalette.gtBlue.uiColor)
                )
            }.frame(height: 45).overlay(
                Text(viewModel.allowNotificationsActionTitle)
                    .foregroundColor(
                        .white
                    )
            )

            Button(action: {
                viewModel.maybeLaterTapped()

            }) {
                Text(viewModel.maybeLaterActionTitle)
                    .foregroundColor(
                        Color(
                            uiColor: ColorPalette.gtBlue.uiColor
                        )
                    )
            }
            .frame(height: 40).padding(
                .bottom,
                50
            )
        }.padding(.horizontal, 20).background(
            RoundedRectangle(
                cornerRadius: 10
            ).stroke(
                Color(uiColor: ColorPalette.gtBlue.uiColor),
                lineWidth: 8
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10).foregroundStyle(
                    .white
                )
            )
        )
        .padding(.horizontal, UIScreen.main.bounds.width * 0.05)

    }

}

// MARK: - Preview

struct OptInNotificationView_Preview: PreviewProvider {

    static func getOptInNotificationViewModel() -> OptInNotificationViewModel {

        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer()
            .getAppDiContainer()

        let viewModel = OptInNotificationViewModel(

            optInNotificationRepository: appDiContainer.feature
                .optInNotification.dataLayer
                .getOptInNotificationRepository(),
            launchCountRepository: appDiContainer.feature.optInNotification
                .dataLayer.getLaunchCountRepository(),
            viewOptInNotificationUseCase: appDiContainer.feature
                .optInNotification.domainLayer
                .getViewOptInNotificationUseCase(),
            viewOptInDialogUseCase: appDiContainer.feature.optInNotification
                .domainLayer.getViewOptInDialogUseCase(),
            requestNotificationPermissionUseCase: appDiContainer.feature
                .optInNotification.domainLayer
                .getRequestNotificationPermissionUseCase(),
            checkNotificationStatusUseCase: appDiContainer.feature
                .optInNotification.domainLayer
                .getCheckNotificationStatusUseCase(),

            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase(),
            flowDelegate: MockFlowDelegate()

        )

        return viewModel
    }

    static var previews: some View {

        OptInNotificationView(
            viewModel:
                OptInNotificationView_Preview.getOptInNotificationViewModel()
        )
    }
}
