//
//  ToolsMenuView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ToolsMenuView: UIViewController {
    
    private let viewModel: ToolsMenuViewModelType
    private let pageOrder: [ToolsMenuPageType] = [.lessons, .favoritedTools, .allTools]
    
    private var startingPage: ToolsMenuPageType = .favoritedTools
    private var pages: [ToolsMenuPageType: ToolsMenuPageView] = Dictionary()
    private var isAnimatingNavigationToPage: Bool = false
    private var chooseLanguageButton: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
                
    @IBOutlet weak private var toolsListsScrollView: UIScrollView!
    @IBOutlet weak private var toolbarView: ToolsMenuToolbarView!
    @IBOutlet weak private var bottomView: UIView!
            
    required init(viewModel: ToolsMenuViewModelType, startingPage: ToolsMenuPageType) {
        
        self.viewModel = viewModel
        self.startingPage = startingPage
        super.init(nibName: String(describing: ToolsMenuView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        
        _ = addBarButtonItem(
            to: .left,
            image: ImageCatalog.navMenu.image,
            color: .white,
            target: self,
            action: #selector(menuButtonTapped(barButtonItem:))
        )
    }
    
    private func setupLayout() {

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
        
        for index in 0 ..< pageOrder.count {
            
            let pageType: ToolsMenuPageType = pageOrder[index]
            let page: ToolsMenuPageView = getNewPageViewInstance(pageType: pageType)
            
            pages[pageType] = page
                        
            page.view.frame = CGRect(
                x: CGFloat(index) * toolsListsScrollView.bounds.size.width,
                y: 0,
                width: toolsListsScrollView.bounds.size.width,
                height: toolsListsScrollView.bounds.size.height
            )
                        
            toolsListsScrollView.addSubview(page.view)
            
            toolsListsScrollView.contentSize = CGSize(
                width: toolsListsScrollView.bounds.size.width * CGFloat(index + 1),
                height: toolsListsScrollView.bounds.size.height
            )
        }
                
        toolsListsScrollView.delegate = self
        
        toolbarView.configure(viewModel: viewModel.toolbarWillAppear(), pageItemsOrder: pageOrder, delegate: self)
                                
        navigateToPage(pageType: startingPage, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBarAppearance(shouldAnimateNavigationBarHiddenState: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if let mostVisiblePageType = getMostVisiblePage() {
            toolsMenuPageDidAppear(pageType: mostVisiblePageType)
        }
    }
    
    @objc private func menuButtonTapped(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc private func chooseLanguageButtonTapped(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    func reset(toolbarItem: ToolsMenuPageType, animated: Bool) {
        
        // TODO: Need to implement GT-1545 before Cru22 and before merging iOS 13 branch. ~Levi
        // https://jira.cru.org/browse/GT-1545
        
        guard didLayoutSubviews else {
            startingPage = toolbarItem
            return
        }
        
        guard self.view != nil else {
            return
        }
        
        pages[.lessons]?.scrollToTop(animated: false)
        pages[.favoritedTools]?.scrollToTop(animated: false)
        pages[.allTools]?.scrollToTop(animated: false)
                
        navigateToPage(pageType: toolbarItem, animated: animated)
    }
    
    private func getNewPageViewInstance(pageType: ToolsMenuPageType) -> ToolsMenuPageView {
        
        switch pageType {
        
        case .allTools:
            return AllToolsView(contentView: AllToolsContentView(viewModel: viewModel.allToolsWillAppear()))
            
        case .favoritedTools:
            let favoritedToolsView = FavoritedToolsView(contentView: FavoritesContentView(viewModel: viewModel.favoritedToolsWillAppear()))
            favoritedToolsView.setDelegate(delegate: self)
            return favoritedToolsView
        
        case .lessons:
            return LessonsListView(viewModel: viewModel.lessonsWillAppear())
        }
    }
    
    private func configureNavigationBarAppearance(shouldAnimateNavigationBarHiddenState: Bool) {
                
        AppDelegate.setWindowBackgroundColorForStatusBarColor(color: ColorPalette.primaryNavBar.uiColor)
        
        navigationController?.setNavigationBarHidden(false, animated: shouldAnimateNavigationBarHiddenState)
                
        navigationController?.navigationBar.setupNavigationBarAppearance(
            backgroundColor: ColorPalette.primaryNavBar.uiColor,
            controlColor: .white,
            titleFont: viewModel.navTitleFont,
            titleColor: .white,
            isTranslucent: false
        )
    }
        
    private func toolsMenuPageDidAppear(pageType: ToolsMenuPageType) {
        
        pages[pageType]?.pageViewed()
    }
    
    private func didChangeToolbarItem(pageType: ToolsMenuPageType) {
        
        let hidesChooseLanguageButton: Bool
        
        switch pageType {
        case .lessons:
            hidesChooseLanguageButton = true
        case .allTools:
            hidesChooseLanguageButton = false
        case .favoritedTools:
            hidesChooseLanguageButton = false
        }
        
        setChooseLanguageButtonHidden(hidden: hidesChooseLanguageButton)
        
        toolbarView.setSelectedToolbarItem(pageType: pageType)
    }
    
    private func navigateToPage(pageType: ToolsMenuPageType, animated: Bool) {
        
        guard toolsListsScrollView != nil else {
            return
        }
        
        guard let page = pageOrder.firstIndex(of: pageType) else {
            return
        }
                
        if animated {
            isAnimatingNavigationToPage = true
        }
        
        toolsListsScrollView.setContentOffset(
            CGPoint(x: toolsListsScrollView.bounds.size.width * CGFloat(page), y: 0),
            animated: animated
        )
        
        didChangeToolbarItem(pageType: pageType)
    }
    
    private func setChooseLanguageButtonHidden(hidden: Bool) {
        
        if hidden, let chooseLanguageButton = self.chooseLanguageButton {
            
            removeBarButtonItem(item: chooseLanguageButton, barPosition: .right)
            self.chooseLanguageButton = nil
        }
        else if !hidden && chooseLanguageButton == nil {
            
            chooseLanguageButton = addBarButtonItem(
                to: .right,
                image: ImageCatalog.navLanguage.image,
                color: .white,
                target: self,
                action: #selector(chooseLanguageButtonTapped(barButtonItem:))
            )
        }
    }
        
    private func getMostVisiblePage() -> ToolsMenuPageType? {
        
        let mostVisiblePageType: ToolsMenuPageType?
        let middleContentOffset: CGFloat = toolsListsScrollView.contentOffset.x + (toolsListsScrollView.bounds.size.width / 2)
        
        var mostVisiblePageIndex: Int = Int(middleContentOffset / toolsListsScrollView.bounds.size.width)
        
        if mostVisiblePageIndex < 0 {
            mostVisiblePageIndex = 0
        }
        else if mostVisiblePageIndex >= pageOrder.count {
            mostVisiblePageIndex = pageOrder.count - 1
        }
        
        if mostVisiblePageIndex >= 0 && mostVisiblePageIndex < pageOrder.count {
            mostVisiblePageType = pageOrder[mostVisiblePageIndex]
        }
        else {
            mostVisiblePageType = nil
        }
        
        return mostVisiblePageType
    }
}

// MARK: - UIScrollViewDelegate

extension ToolsMenuView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == toolsListsScrollView,
           !isAnimatingNavigationToPage,
           let mostVisiblePageType = getMostVisiblePage() {
            
            didChangeToolbarItem(pageType: mostVisiblePageType)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == toolsListsScrollView {
            isAnimatingNavigationToPage = false
            
            if let mostVisiblePageType = getMostVisiblePage() {
                toolsMenuPageDidAppear(pageType: mostVisiblePageType)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == toolsListsScrollView, let mostVisiblePageType = getMostVisiblePage() {
            toolsMenuPageDidAppear(pageType: mostVisiblePageType)
        }
    }
}

// MARK: - FavoritedToolsViewDelegate

extension ToolsMenuView: FavoritedToolsViewDelegate {
    
    func favoritedToolsViewFindToolsTapped(favoritedToolsView: FavoritedToolsView) {
              
        navigateToPage(pageType: .allTools, animated: true)
    }
}

// MARK: - ToolsMenuToolbarViewDelegate

extension ToolsMenuView: ToolsMenuToolbarViewDelegate {
    
    func toolsMenuToolbarLessonsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToPage(pageType: .lessons, animated: true)
    }
    
    func toolsMenuToolbarFavoritedToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToPage(pageType: .favoritedTools, animated: true)
    }
    
    func toolsMenuToolbarAllToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToPage(pageType: .allTools, animated: true)
    }
}
