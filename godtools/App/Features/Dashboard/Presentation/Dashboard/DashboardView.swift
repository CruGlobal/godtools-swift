//
//  DashboardView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine
import SwiftUI

struct DashboardView: View {

    static let contentHorizontalInsets: CGFloat = 16
    static let toolCardVerticalSpacing: CGFloat = 15
    static let scrollViewBottomSpacingToTabBar: CGFloat = 30

    @ObservedObject private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {

        self.viewModel = viewModel
    }

    func checkNotificationStatus() async -> String {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized:
            print("NotificationStatus: Enabled")
            return "Enabled"
        case .denied:
            print("NotificationStatus: Denied")
            return
                "Denied"
        case .notDetermined:
            print("NotificationStatus: Undetermined")
            return "Undetermined"
        case .provisional:
            return
                "Provisional"
        case .ephemeral:
            return
                "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }

    var body: some View {

        GeometryReader { geometry in

            VStack(alignment: .center, spacing: 0) {

                Button(action: {

                    Task {
                        let notificationStatus = await checkNotificationStatus()

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        guard
                            let lastPrompted = dateFormatter.date(
                                from: "2025-3-1")
                        else { return }

                        // Get the current date
                        let currentDate = Date()

                        // Calculate two months ago
                        let calendar = Calendar.current
                        let twoMonthsAgo = calendar.date(
                            byAdding: .month, value: -2, to: currentDate)!

                        if notificationStatus != "Approved" {
                            if notificationStatus == "Undetermined" {
                                print("Detected undetermined status")
                                bottomSheetPosition = .dynamicTop

                            } else if notificationStatus == "Denied"
                                && lastPrompted < twoMonthsAgo
                            {
                                print(
                                    "Previously denied but last prompt was more than two months ago."
                                )
                                bottomSheetPosition = .dynamicTop
                            } else if notificationStatus == "Denied"
                                && lastPrompted > twoMonthsAgo
                            {
                                print(
                                    "Previously denied and prompted recently.")
                            }
                        }
                    }

                }) {

                    Text("Show Dialog")
                }

                if viewModel.tabs.count > 0 {

                    TabView(selection: $viewModel.currentTab) {

                        Group {

                            if ApplicationLayout.shared.layoutDirection
                                == .rightToLeft
                            {

                                ForEach(
                                    (0..<viewModel.tabs.count).reversed(),
                                    id: \.self
                                ) { index in

                                    getDashboardPageView(index: index)
                                        .environment(
                                            \.layoutDirection,
                                            ApplicationLayout.shared
                                                .layoutDirection
                                        )
                                        .tag(index)
                                }
                            } else {

                                ForEach(0..<viewModel.tabs.count, id: \.self) {
                                    index in

                                    getDashboardPageView(index: index)
                                        .environment(
                                            \.layoutDirection,
                                            ApplicationLayout.shared
                                                .layoutDirection
                                        )
                                        .tag(index)
                                }
                            }
                        }
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeOut, value: viewModel.currentTab)

                    DashboardTabBarView(
                        viewModel: viewModel
                    )
                }
            }
        }
        .environment(
            \.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }

    @ViewBuilder private func getDashboardPageView(index: Int) -> some View {

        switch viewModel.tabs[index] {

        case .lessons:
            LessonsView(viewModel: viewModel.getLessonsViewModel())

        case .favorites:
            FavoritesView(viewModel: viewModel.getFavoritesViewModel())

        case .tools:
            ToolsView(viewModel: viewModel.getToolsViewModel())
        }
    }
}

extension DashboardView {

    func getCurrentTab() -> DashboardTabTypeDomainModel {
        return viewModel.getTab(tabIndex: viewModel.currentTab) ?? .favorites
    }

    func navigateToTab(tab: DashboardTabTypeDomainModel) {

        viewModel.tabTapped(tab: tab)
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {

    private static let diContainer: AppDiContainer = SwiftUIPreviewDiContainer()
        .getAppDiContainer()
    private static let flowDelegate: FlowDelegate = MockFlowDelegate()
    private static let dashboardDependencies:
        DashboardPresentationLayerDependencies =
            DashboardPresentationLayerDependencies(
                appDiContainer: Self.diContainer,
                flowDelegate: Self.flowDelegate)

    static func getDashboardViewModel() -> DashboardViewModel {

        let appDiContainer: AppDiContainer = Self.diContainer

        let viewModel = DashboardViewModel(
            startingTab: .favorites,
            flowDelegate: Self.flowDelegate,
            dashboardPresentationLayerDependencies: Self.dashboardDependencies,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase(),
            viewDashboardUseCase: appDiContainer.feature.dashboard.domainLayer
                .getViewDashboardUseCase(),
            dashboardTabObserver: CurrentValueSubject(.favorites)
        )

        return viewModel
    }

    static var previews: some View {

        DashboardView(viewModel: Self.getDashboardViewModel())
    }
}

// DSR
// TODO:
// - Adaptive sizing
// - Import assets (1x, 2x, 3x)
struct NotificationsSheetView: View {
    @Binding var bottomSheetPosition: BottomSheetPosition

    func requestNotificationPermission() {

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notifications allowed")
                } else {
                    print("Notifications denied")
                    showSettingsAlert()
                }
            }
        }

    }

    func showSettingsAlert() {
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
                UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(
                UIAlertAction(title: "Settings", style: .default) { _ in
                    UIApplication.shared.open(
                        settingsURL, options: [:], completionHandler: nil)
                })

            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    var body: some View {
        ZStack {
            if bottomSheetPosition == .dynamicTop {
                Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)
            }

            Color.clear.bottomSheet(
                bottomSheetPosition: $bottomSheetPosition,
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
                            // settings prompt
                            // dismiss bottom sheet
                            requestNotificationPermission()
                        }) {
                            RoundedRectangle(cornerRadius: 5).fill(
                                Color(uiColor: ColorPalette.gtBlue.uiColor))
                        }.frame(height: 45).overlay(
                            Text("Allow Notifications").foregroundColor(
                                .white)
                        )

                        Button(action: {
                            bottomSheetPosition = .hidden
                        }) {
                            Text("Maybe Later").foregroundColor(
                                Color(uiColor: ColorPalette.gtBlue.uiColor))
                        }
                        .frame(height: 40).padding(
                            .bottom, 50
                        )
                    }.padding(.horizontal, 20)
                }
            ).showDragIndicator(false)
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
