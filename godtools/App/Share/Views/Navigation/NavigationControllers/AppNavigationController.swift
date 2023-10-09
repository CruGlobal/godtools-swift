//
//  AppNavigationController.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class AppNavigationController: UINavigationController {
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApplicationLayout.shared.semanticContentAttributePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (semanticContentAttribute: UISemanticContentAttribute) in
                
                self?.view.semanticContentAttribute = semanticContentAttribute
                self?.navigationBar.semanticContentAttribute = semanticContentAttribute
                
                let viewControllers: [UIViewController] = self?.viewControllers ?? Array()
                
                // NOTE: This forloop is here to reload SwiftUI view's that have a TabView.  It feels like a hacky solution, but it's the only solution I can come up with.  Due to a bug in iOS 16.3.1 TabView not updating correctly for right to left languages.  TabViews have to be forced in a left to right language direction and then the contents are manually created based on the language direction. ~Levi
                
                for viewController in viewControllers {
                    
                    if let dashboardHostingView = viewController as? AppHostingController<DashboardView> {
                        let currentTab: DashboardTabTypeDomainModel = dashboardHostingView.rootView.getCurrentTab()
                        dashboardHostingView.rootView.navigateToTab(tab: currentTab)
                    }
                    else if let onboardingTutorialHostingView = viewController as? AppHostingController<OnboardingTutorialView> {
                        let currentPage: Int = onboardingTutorialHostingView.rootView.getCurrentPage()
                        onboardingTutorialHostingView.rootView.setCurrentPage(page: currentPage)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
