//
//  AppNavigationBar.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppNavigationBar {
    
    private let navBarAppearance: AppNavigationBarAppearance?
    private let backButton: AppBackBarItem?
    private let leadingItems: [NavBarItem]
    private let trailingItems: [NavBarItem]
    private let initialTitleView: UIView?
    private let initialTitle: String?
    private let layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>
    
    private var leadingItemControllers: [NavBarItemController] = Array()
    private var trailingItemControllers: [NavBarItemController] = Array()
    private var titleView: UIView?
    private var title: String?
    private var layoutDirection: UISemanticContentAttribute = .forceLeftToRight
    private var cancellables: Set<AnyCancellable> = Set()
    private var didConfigure: Bool = false
        
    private weak var viewController: UIViewController?
    
    init(appearance: AppNavigationBarAppearance?, backButton: AppBackBarItem?, leadingItems: [NavBarItem], trailingItems: [NavBarItem], titleView: UIView? = nil, title: String? = nil, layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>? = nil) {
        
        self.navBarAppearance = appearance
        self.backButton = backButton
        self.leadingItems = leadingItems
        self.trailingItems = trailingItems
        self.initialTitleView = titleView
        self.initialTitle = title
        self.titleView = titleView
        self.title = title
        self.layoutDirectionPublisher = layoutDirectionPublisher ?? ApplicationLayout.shared.semanticContentAttributePublisher
    }
    
    private static func getItemControllers(delegate: NavBarItemControllerDelegate, navBarAppearance: AppNavigationBarAppearance?, items: [NavBarItem], barPosition: BarButtonItemBarPosition) -> [NavBarItemController] {
        
        var itemControllers: [NavBarItemController] = Array()
        
        for index in 0 ..< items.count {
            
            let navBarItem: NavBarItem = items[index]
            
            let controller = NavBarItemController.newNavBarItemController(
                controllerType: navBarItem.controllerType,
                delegate: delegate,
                navBarAppearance: navBarAppearance,
                navBarItem: navBarItem,
                itemBarPosition: barPosition,
                itemIndex: index
            )
            
            itemControllers.append(controller)
        }
        
        return itemControllers
    }
    
    func resetToInitialState() {
        
        guard let viewController = self.viewController else {
            return
        }
        
        didConfigure = false
        
        configureIfNeeded(viewController: viewController)
    }
    
    private var uiNavigationBar: UINavigationBar? {
        return viewController?.navigationController?.navigationBar
    }
    
    private var uiNavigationItem: UINavigationItem? {
        return viewController?.navigationItem
    }
    
    private func configureIfNeeded(viewController: UIViewController) {
        
        guard !didConfigure else {
            return
        }
        
        didConfigure = true
        
        reconfigureAppearance()
        
        reconfigureButtonItems()
                
        if let titleView = self.titleView {
            setTitleView(titleView: titleView)
        }
        else if let title = title {
            setTitle(title: title)
        }
        
        layoutDirectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (layoutDirection: UISemanticContentAttribute) in
                self?.viewController?.navigationController?.navigationBar.semanticContentAttribute = layoutDirection
                self?.layoutDirection = layoutDirection
                self?.redrawBarButtonItems()
            }
            .store(in: &cancellables)
    }
    
    func willAppear(viewController: UIViewController, animated: Bool) {
         
        self.viewController = viewController
        
        configureIfNeeded(viewController: viewController)
    }
}

// MARK: - NavBarItemControllerDelegate

extension AppNavigationBar: NavBarItemControllerDelegate {
    
    func didChangeBarButtonItemState(controller: NavBarItemController) {
        redrawBarButtonItems()
    }
}

// MARK: - Appearance

extension AppNavigationBar {
        
    private func getNearestNavBarAppearance() -> AppNavigationBarAppearance? {
        
        if let navBarAppearance = self.navBarAppearance {
            return navBarAppearance
        }
        
        var parent: UIViewController? = viewController
        
        while let appNavigationController = parent?.navigationController as? AppNavigationController {
            
            if let navBarAppearance = appNavigationController.navigationBarAppearance {
                return navBarAppearance
            }
            else {
                parent = appNavigationController
            }
        }
        
        return nil
    }
    
    func reconfigureAppearance() {
        
        guard let appearance = navBarAppearance else {
            return
        }
        
        setApperance(navigationBarAppearance: appearance)
    }
    
    private func setApperance(navigationBarAppearance: AppNavigationBarAppearance) {
    
        guard let navigationBar = uiNavigationBar else {
            return
        }
        
        AppNavigationBar.setAppearance(navigationBar: navigationBar, navigationBarAppearance: navigationBarAppearance)
    }
    
    static func setAppearance(navigationBar: UINavigationBar, navigationBarAppearance: AppNavigationBarAppearance) {
        
        navigationBar.isTranslucent = navigationBarAppearance.isTranslucent
        
        if let controlColor = navigationBarAppearance.controlColor {
            navigationBar.tintColor = controlColor
        }
                
        if !navigationBarAppearance.titleTextAttributes.isEmpty {
            navigationBar.titleTextAttributes = navigationBarAppearance.titleTextAttributes
        }
        
        let appearance = UINavigationBarAppearance()
                    
        if navigationBarAppearance.isTranslucent {
            
            appearance.configureWithTransparentBackground()
            appearance.backgroundImage = UIImage.createImageWithColor(color: navigationBarAppearance.backgroundColor)
            appearance.backgroundColor = .clear
        }
        else {
            
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = nil
            appearance.backgroundColor = navigationBarAppearance.backgroundColor
        }
        
        appearance.shadowColor = .clear
        
        if !navigationBarAppearance.titleTextAttributes.isEmpty {
            appearance.titleTextAttributes = navigationBarAppearance.titleTextAttributes
        }
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
    }
}

// MARK: - Title

extension AppNavigationBar {
    
    func getTitleView() -> UIView? {
        return titleView
    }
    
    func setTitleView(titleView: UIView?) {
        
        self.titleView = titleView
        
        viewController?.title = nil
        viewController?.navigationItem.titleView = titleView
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func setTitle(title: String?) {
        
        self.title = title
        
        viewController?.navigationItem.titleView = nil
        viewController?.title = title
    }
}

// MARK - Button Items

extension AppNavigationBar {
    
    private func reconfigureButtonItems() {
        
        guard let viewController = self.viewController else {
            return
        }
        
        removeAllBarButtonItems()
        
        leadingItemControllers.removeAll()
        trailingItemControllers.removeAll()
        
        var leadingItemsWithBackButton: [NavBarItem] = leadingItems
        
        viewController.navigationItem.setHidesBackButton(true, animated: false)
        
        if let backButton = self.backButton {
            leadingItemsWithBackButton.insert(backButton, at: 0)
        }
        
        let navBarAppearance: AppNavigationBarAppearance? = getNearestNavBarAppearance()
        
        leadingItemControllers = AppNavigationBar.getItemControllers(
            delegate: self,
            navBarAppearance: navBarAppearance,
            items: leadingItemsWithBackButton,
            barPosition: .leading
        )
        
        trailingItemControllers = AppNavigationBar.getItemControllers(
            delegate: self,
            navBarAppearance: navBarAppearance,
            items: trailingItems,
            barPosition: .trailing
        )
        
        redrawBarButtonItems()
    }
    
    private func redrawBarButtonItems() {
        
        removeAllBarButtonItems()
        
        let leadingItemControllers: [NavBarItemController]
        let trailingItemControllers: [NavBarItemController]
        
        let systemIsRightToLeft: Bool = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        let layoutDirectionIsRightToLeft: Bool = layoutDirection == .forceRightToLeft
        
        if layoutDirectionIsRightToLeft && !systemIsRightToLeft || systemIsRightToLeft && !layoutDirectionIsRightToLeft {
            
            leadingItemControllers = self.leadingItemControllers.reversed()
            trailingItemControllers = self.trailingItemControllers.reversed()
        }
        else {
            
            leadingItemControllers = self.leadingItemControllers
            trailingItemControllers = self.trailingItemControllers
        }
                
        for leadingItemController in leadingItemControllers {
            
            if !leadingItemController.barButtonItemIsHidden, let barButtonItem = leadingItemController.getBarButtonItem() {
                addLeadingBarButtonItem(item: barButtonItem, index: nil)
            }
        }
        
        for trailingItemController in trailingItemControllers {
            
            if !trailingItemController.barButtonItemIsHidden, let barButtonItem = trailingItemController.getBarButtonItem() {
                addTrailingBarButtonItem(item: barButtonItem, index: nil)
            }
        }
    }
    
    private func addLeadingBarButtonItem(item: UIBarButtonItem, index: Int?) {
        
        guard let navigationItem = uiNavigationItem else {
            return
        }
        
        if var leadingItems = navigationItem.leftBarButtonItems, !leadingItems.isEmpty {
            
            if !leadingItems.contains(item) {
                
                if let index = index, index >= 0 && index < leadingItems.count {
                    
                    leadingItems.insert(item, at: index)
                }
                else {
                    
                    leadingItems.append(item)
                }
                
                navigationItem.leftBarButtonItems = leadingItems
            }
        }
        else {
            
            navigationItem.leftBarButtonItem = item
        }
    }

    private func addTrailingBarButtonItem(item: UIBarButtonItem, index: Int?) {
        
        guard let navigationItem = uiNavigationItem else {
            return
        }
        
        if var trailingItems = navigationItem.rightBarButtonItems, !trailingItems.isEmpty {
            
            if !trailingItems.contains(item) {
                
                if let index = index, index >= 0 && index < trailingItems.count {
                    
                    trailingItems.insert(item, at: index)
                }
                else {
                    
                    trailingItems.append(item)
                }
                
                navigationItem.rightBarButtonItems = trailingItems
            }
        }
        else {
            
            navigationItem.rightBarButtonItem = item
        }
    }
    
    private func removeAllBarButtonItems() {
        
        guard let navigationItem = uiNavigationItem else {
            return
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.leftBarButtonItems = Array()
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = Array()
    }
}
