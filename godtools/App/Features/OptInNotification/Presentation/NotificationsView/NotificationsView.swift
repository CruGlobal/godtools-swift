//
//  OptInBottomSheet.swift
//  godtools
//
//  Created by Jason Bennett on 3/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import BottomSheet
import Foundation
import SwiftUI

// DSR
// TODO:
// - Adaptive sizing
// - Disable appbar while active
// - Import assets (1x, 2x, 3x)
// - First app use strategy
// - /n in Localizable Base

struct NotificationsView: View {
    @ObservedObject private var viewModel: NotificationsViewModel

    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if viewModel.bottomSheetPosition == .dynamicTop {
                Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)
            }

            Color.clear.bottomSheet(
                bottomSheetPosition: $viewModel.bottomSheetPosition,
                switchablePositions: [.hidden, .dynamicTop],
                headerContent: {},
                mainContent: {
                    VStack {
                        Image("notifications_graphic").resizable()
                            .scaledToFit()
                            .padding(
                                EdgeInsets(
                                    top: 5, leading: 5, bottom: 0,
                                    trailing: 5)
                            ).overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(
                                        Color(
                                            uiColor: ColorPalette.gtBlue
                                                .uiColor
                                        )),
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
                                .vertical, 10
                            ).minimumScaleFactor(0.5).lineLimit(1)

                        Text(
                            viewModel.body
                        ).font(FontLibrary.sfProTextRegular.font(size: 18))
                            .foregroundStyle(ColorPalette.gtGrey.color)
                            .multilineTextAlignment(.center).padding(
                                .bottom, 12)

                        Button(action: {
                            viewModel.allowNotificationsTapped()

                        }) {
                            RoundedRectangle(cornerRadius: 5).fill(
                                Color(uiColor: ColorPalette.gtBlue.uiColor))
                        }.frame(height: 45).overlay(
                            Text(viewModel.allowNotificationsActionTitle)
                                .foregroundColor(
                                    .white)
                        )

                        Button(action: {
                            viewModel.bottomSheetPosition = .hidden

                        }) {
                            Text(viewModel.maybeLaterActionTitle)
                                .foregroundColor(
                                    Color(uiColor: ColorPalette.gtBlue.uiColor))
                        }
                        .frame(height: 40).padding(
                            .bottom, 50
                        )
                    }.padding(.horizontal, 20)
                }
            ).showDragIndicator(false).enableFloatingIPadSheet(true)
                .customBackground(
                    RoundedRectangle(
                        cornerRadius: 10
                    ).stroke(
                        Color(uiColor: ColorPalette.gtBlue.uiColor),
                        lineWidth: 8
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).foregroundStyle(
                            .white))
                )
                .padding(.horizontal, UIScreen.main.bounds.width * 0.05)

        }
    }
}

// MARK: - Preview

struct NotificationsView_Preview: PreviewProvider {

    static func getNotificationsViewModel() -> NotificationsViewModel {

        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer()
            .getAppDiContainer()

        let viewModel = NotificationsViewModel(

            viewOptInNotificationsUseCase: appDiContainer.feature
                .optInNotification.domainLayer
                .getViewOptInNotificationsUseCase(),

            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase()

        )

        return viewModel
    }

    static var previews: some View {

        NotificationsView(
            viewModel: NotificationsView_Preview.getNotificationsViewModel()
        )
    }
}
