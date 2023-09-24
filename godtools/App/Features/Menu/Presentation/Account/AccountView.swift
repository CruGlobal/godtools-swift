//
//  AccountView.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountView: View {
    
    @ObservedObject private var viewModel: AccountViewModel
        
    init(viewModel: AccountViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
               
            PullToRefreshScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                                        
                    AccountUserDetailsView(viewModel: viewModel)
                                        
                    AccountSectionsView(viewModel: viewModel, geometry: geometry)
                }
                
            } refreshHandler: {
                
                viewModel.pullToRefresh()
            }
        }
        .navigationTitle(viewModel.navTitle)
        .navigationBarBackButtonHidden(true)
        .background(Color.getColorWithRGB(red: 245, green: 245, blue: 245, opacity: 1))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct AccountView_Preview: PreviewProvider {
    
    static func getAccountViewModel() -> AccountViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        return AccountViewModel(
            flowDelegate: MockFlowDelegate(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getUserAccountDetailsUseCase: appDiContainer.domainLayer.getUserAccountDetailsUseCase(),
            getUserActivityUseCase: appDiContainer.domainLayer.getUserActivityUseCase(),
            getGlobalActivityThisWeekUseCase: appDiContainer.domainLayer.getGlobalActivityThisWeekUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
    }
    
    static var previews: some View {
        
        AccountView(
            viewModel: AccountView_Preview.getAccountViewModel()
        )
    }
}
