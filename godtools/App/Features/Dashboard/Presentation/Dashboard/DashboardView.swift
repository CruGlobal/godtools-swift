//
//  DashboardView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import BottomSheet
import Combine
import SwiftUI

struct DashboardView: View {

    static let contentHorizontalInsets: CGFloat = 16
    static let toolCardVerticalSpacing: CGFloat = 15
    static let scrollViewBottomSpacingToTabBar: CGFloat = 30

    @ObservedObject private var viewModel: DashboardViewModel

    init(
        viewModel: DashboardViewModel
    ) {
        self.viewModel = viewModel
    }

    func checkNotificationStatus() async -> String {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            print("NotificationStatus: Enabled")
            return "Enabled"
        case .denied:
            print("NotificationStatus: Denied")
            return
                "Denied"
        case .notDetermined:
            print("NotificationStatus: Undetermined")
            return "Undetermined"
        @unknown default:
            return "Unknown"
        }
    }

    func recordLastPrompt() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        guard let testDate = dateFormatter.date(from: "01/01/2025") else {
            print("Failed to create date from string.")
            return
        }

        let dateString = dateFormatter.string(from: testDate)
        UserDefaults.standard.set(dateString, forKey: "lastPrompted")
        print("set lastPrompted to: \(dateString)")
    }

    func shouldPromptNotificationsSheet() {
        Task {
            let notificationStatus = await checkNotificationStatus()

            // Retrieve lastPrompted date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let lastPrompted = UserDefaults.standard.string(
                forKey: "lastPrompted")
            let lastPromptedDate =
                lastPrompted.flatMap {
                    dateFormatter.date(from: $0)
                } ?? Date.distantPast

            // Get current date
            let currentDate = Date()
            let calendar = Calendar.current
            let twoMonthsAgo = calendar.date(
                byAdding: .month, value: -2, to: currentDate)!

            if notificationStatus != "Approved" {
                if notificationStatus == "Undetermined" {
                    print("Detected undetermined status")
                    viewModel.getNotificationsViewModel().bottomSheetPosition =
                        .dynamicTop
                    recordLastPrompt()
                } else if notificationStatus == "Denied"
                    && lastPromptedDate < twoMonthsAgo
                {
                    print(
                        "Previously denied but last prompt was more than two months ago."
                    )
                    print(
                        "Bottom sheet position before: \(viewModel.getNotificationsViewModel().bottomSheetPosition)"
                    )
                    viewModel.getNotificationsViewModel().bottomSheetPosition =
                        .dynamicTop
                    print(
                        "Bottom sheet position after : \(viewModel.getNotificationsViewModel().bottomSheetPosition)"
                    )
                    recordLastPrompt()
                } else if notificationStatus == "Denied"
                    && lastPromptedDate > twoMonthsAgo
                {
                    print(
                        "Previously denied and prompted recently.")
                    recordLastPrompt()

                }
            }  // already approved
        }
    }

    var body: some View {

        GeometryReader { geometry in

            VStack(alignment: .center, spacing: 0) {

                Button(action: {
                    shouldPromptNotificationsSheet()
                }) {

                    Text("shouldPromptNotificationsSheet()")
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
            }.overlay(
                //need align?
                alignment: Alignment.center,
                content: {
                    NotificationsView(
                        viewModel: viewModel.getNotificationsViewModel()
                    )
                }
            )
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

        DashboardView(
            viewModel: Self.getDashboardViewModel())
    }
}
