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
    @ObservedObject private var optInNotificationModel:
    OptInNotificationViewModel

    init(
        viewModel: DashboardViewModel,
        optInNotificationViewModel: OptInNotificationViewModel
    ) {
        self.viewModel = viewModel
        self.optInNotificationModel = optInNotificationViewModel
    }

    var body: some View {

        GeometryReader { geometry in

            VStack(alignment: .center, spacing: 0) {

                Button(action: {
                    Task {
                        await viewModel.getOptInNotificationViewModel()
                            .shouldPromptNotificationSheet()
                    }

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
            }.overlay(content: {
                if optInNotificationModel.isActive {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                }

            }).overlay(
                alignment: Alignment.bottom,
                content: {
                    if optInNotificationModel.isActive {

                        OptInNotificationView(
                            viewModel:
                                viewModel.getOptInNotificationViewModel()
                        ).transition(.move(edge: .bottom))

                    }
                }
            )
        }
        .environment(
            \.layoutDirection,
            ApplicationLayout.shared.layoutDirection
        )
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
                flowDelegate: Self.flowDelegate
            )

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
            viewModel: Self.getDashboardViewModel(),
            optInNotificationViewModel: dashboardDependencies
                .optInNotificationViewModel
        )
    }
}
