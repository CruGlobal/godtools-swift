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
// - Disable appbar
// - Import assets (1x, 2x, 3x)
// - First app use strategy
struct NotificationsView: View {
    @ObservedObject private var viewModel: NotificationsViewModel

    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
    }

    func requestNotificationPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert, .badge, .sound,
            ]) { granted, error in

                continuation.resume(returning: granted)
            }
        }
    }

    func showSettingsAlert(completion: @escaping () -> Void) {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
        else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene,
            let rootViewController = windowScene.windows.first?
                .rootViewController
        {

            let alert = UIAlertController(
                title: "Enable Notifications",
                message:
                    "Notifications are disabled. Please enable them in Settings.",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion()
                })

            alert.addAction(
                UIAlertAction(title: "Settings", style: .default) { _ in
                    UIApplication.shared.open(
                        settingsURL, options: [:], completionHandler: nil)
                    // Invoke the completion handler after the alert action
                    completion()
                })

            rootViewController.present(alert, animated: true, completion: nil)
        }
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
                        Text("Get Tips and Encouragement")
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
                            "Stay equipped for conversations.\nAllow notifications today."
                        ).font(FontLibrary.sfProTextRegular.font(size: 18))
                            .foregroundStyle(ColorPalette.gtGrey.color)
                            .multilineTextAlignment(.center).padding(
                                .bottom, 12)

                        Button(action: {
                            Task {
                                let granted =
                                    await requestNotificationPermission()

                                if granted {
                                    print("granted")
                                    viewModel.bottomSheetPosition = .hidden
                                } else {
                                    print("not granted")
                                    await withCheckedContinuation {
                                        continuation in
                                        showSettingsAlert {
                                            // Once the user has interacted with the alert, continue and hide the bottom sheet
                                            continuation.resume()
                                            viewModel.bottomSheetPosition =
                                                .hidden
                                        }
                                    }
                                }

                            }

                        }) {
                            RoundedRectangle(cornerRadius: 5).fill(
                                Color(uiColor: ColorPalette.gtBlue.uiColor))
                        }.frame(height: 45).overlay(
                            Text("Allow Notifications").foregroundColor(
                                .white)
                        )

                        Button(action: {
                            viewModel.bottomSheetPosition = .hidden

                        }) {
                            Text("Maybe Later").foregroundColor(
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

            viewOptInNotificationsUseCase: ViewOptInNotificationsUseCase(),

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

