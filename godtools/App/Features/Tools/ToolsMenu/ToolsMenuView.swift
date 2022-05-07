//
//  ToolsMenuView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsMenuView: UIViewController {
    
    private let viewModel: ToolsMenuViewModelType
    private let toolsMenuPageOrder: [ToolsMenuPageType] = [.lessons, .favoritedTools, .allTools]
    
    private var startingToolbarItem: ToolsMenuPageType = .favoritedTools
    private var toolsMenuPageViews: [ToolsMenuPageType: ToolsMenuPageView] = Dictionary()
    private var isAnimatingNavigationToToolsMenuPageView: Bool = false
    private var chooseLanguageButton: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
                
    @IBOutlet weak private var toolsListsScrollView: UIScrollView!
    @IBOutlet weak private var toolbarView: ToolsMenuToolbarView!
    @IBOutlet weak private var bottomView: UIView!
            
    required init(viewModel: ToolsMenuViewModelType, startingToolbarItem: ToolsMenuPageType) {
        
        self.viewModel = viewModel
        self.startingToolbarItem = startingToolbarItem
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
        
        for index in 0 ..< toolsMenuPageOrder.count {
            
            let toolsMenuPageType: ToolsMenuPageType = toolsMenuPageOrder[index]
            let toolsMenuPageView: ToolsMenuPageView
            
            switch toolsMenuPageType {
            
            case .allTools:
                let allToolsView: AllToolsView = AllToolsView(viewModel: viewModel.allToolsWillAppear())
                toolsMenuPageView = allToolsView
                
            case .favoritedTools:
                let favoritedToolsView: FavoritedToolsView = FavoritedToolsView(viewModel: viewModel.favoritedToolsWillAppear())
                favoritedToolsView.setDelegate(delegate: self)
                toolsMenuPageView = favoritedToolsView
            
            case .lessons:
                let lessonsView: LessonsListView = LessonsListView(viewModel: viewModel.lessonsWillAppear())
                toolsMenuPageView = lessonsView
            }
            
            toolsMenuPageViews[toolsMenuPageType] = toolsMenuPageView
                        
            toolsMenuPageView.view.frame = CGRect(
                x: CGFloat(index) * toolsListsBounds.size.width,
                y: 0,
                width: toolsListsBounds.size.width,
                height: toolsListsBounds.size.height
            )
                        
            toolsListsScrollView.addSubview(toolsMenuPageView.view)
            
            toolsListsScrollView.contentSize = CGSize(
                width: toolsListsBounds.size.width * CGFloat(index + 1),
                height: toolsListsBounds.size.height
            )
        }
                
        toolsListsScrollView.delegate = self
        
        toolbarView.configure(viewModel: viewModel.toolbarWillAppear(), pageItemsOrder: toolsMenuPageOrder, delegate: self)
                                
        navigateToToolsListForToolbarItem(toolbarItem: startingToolbarItem, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBarAppearance(shouldAnimateNavigationBarHiddenState: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if let mostVisibleItem = getMostVisibleToolsList() {
            toolsMenuPageDidAppear(toolsMenuPageType: mostVisibleItem)
        }
    }
    
    @objc private func menuButtonTapped(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc private func chooseLanguageButtonTapped(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    func reset(toolbarItem: ToolsMenuPageType, animated: Bool) {
        
        guard didLayoutSubviews else {
            startingToolbarItem = toolbarItem
            return
        }
        
        guard self.view != nil else {
            return
        }
        
        toolsMenuPageViews[.lessons]?.scrollToTop(animated: false)
        toolsMenuPageViews[.favoritedTools]?.scrollToTop(animated: false)
        toolsMenuPageViews[.allTools]?.scrollToTop(animated: false)
                
        navigateToToolsListForToolbarItem(toolbarItem: toolbarItem, animated: animated)
    }
    
    private func configureNavigationBarAppearance(shouldAnimateNavigationBarHiddenState: Bool) {
                
        AppDelegate.setWindowBackgroundColorForStatusBarColor(color: ColorPalette.primaryNavBar.color)
        
        navigationController?.setNavigationBarHidden(false, animated: shouldAnimateNavigationBarHiddenState)
                
        navigationController?.navigationBar.setupNavigationBarAppearance(
            backgroundColor: ColorPalette.primaryNavBar.color,
            controlColor: .white,
            titleFont: viewModel.navTitleFont,
            titleColor: .white,
            isTranslucent: false
        )
    }
        
    private func toolsMenuPageDidAppear(toolsMenuPageType: ToolsMenuPageType) {
        
        toolsMenuPageViews[toolsMenuPageType]?.pageViewed()
    }
    
    private func didChangeToolbarItem(toolbarItem: ToolsMenuPageType) {
        
        let hidesChooseLanguageButton: Bool
        
        switch toolbarItem {
        case .lessons:
            hidesChooseLanguageButton = true
        case .allTools:
            hidesChooseLanguageButton = false
        case .favoritedTools:
            hidesChooseLanguageButton = false
        }
        
        setChooseLanguageButtonHidden(hidden: hidesChooseLanguageButton)
        
        toolbarView.setSelectedToolbarItem(toolbarItem: toolbarItem)
    }
    
    private func navigateToToolsListForToolbarItem(toolbarItem: ToolsMenuPageType, animated: Bool) {
        
        guard toolsListsScrollView != nil else {
            return
        }
        
        guard let page = toolbarView.pageItemsOrder.firstIndex(of: toolbarItem) else {
            return
        }
                
        if animated {
            isAnimatingNavigationToToolsMenuPageView = true
        }
        
        toolsListsScrollView.setContentOffset(
            CGPoint(x: toolsListsBounds.size.width * CGFloat(page), y: 0),
            animated: animated
        )
        
        didChangeToolbarItem(toolbarItem: toolbarItem)
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
    
    private var toolsListsBounds: CGRect {
        return toolsListsScrollView.bounds
    }
        
    private func getMostVisibleToolsList() -> ToolsMenuPageType? {
        
        let mostVisibleItem: ToolsMenuPageType?
        let middleContentOffset: CGFloat = toolsListsScrollView.contentOffset.x + (toolsListsBounds.size.width / 2)
        
        var mostVisiblePage: Int = Int(middleContentOffset / toolsListsBounds.size.width)
        
        if mostVisiblePage < 0 {
            mostVisiblePage = 0
        }
        else if mostVisiblePage >= toolbarView.pageItemsOrder.count {
            mostVisiblePage = toolbarView.pageItemsOrder.count - 1
        }
        
        if mostVisiblePage >= 0 && mostVisiblePage < toolbarView.pageItemsOrder.count {
            mostVisibleItem = toolbarView.pageItemsOrder[mostVisiblePage]
        }
        else {
            mostVisibleItem = nil
        }
        
        return mostVisibleItem
    }
}

// MARK: - UIScrollViewDelegate

extension ToolsMenuView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == toolsListsScrollView,
           !isAnimatingNavigationToToolsMenuPageView,
           let mostVisibleItem = getMostVisibleToolsList() {
            
            didChangeToolbarItem(toolbarItem: mostVisibleItem)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == toolsListsScrollView {
            isAnimatingNavigationToToolsMenuPageView = false
            
            if let mostVisibleItem = getMostVisibleToolsList() {
                toolsMenuPageDidAppear(toolsMenuPageType: mostVisibleItem)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == toolsListsScrollView, let mostVisibleItem = getMostVisibleToolsList() {
            toolsMenuPageDidAppear(toolsMenuPageType: mostVisibleItem)
        }
    }
}

// MARK: - FavoritedToolsViewDelegate

extension ToolsMenuView: FavoritedToolsViewDelegate {
    
    func favoritedToolsViewFindToolsTapped(favoritedToolsView: FavoritedToolsView) {
              
        navigateToToolsListForToolbarItem(toolbarItem: .allTools, animated: true)
    }
}

// MARK: - ToolsMenuToolbarViewDelegate

extension ToolsMenuView: ToolsMenuToolbarViewDelegate {
    
    func toolsMenuToolbarLessonsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToToolsListForToolbarItem(toolbarItem: .lessons, animated: true)
    }
    
    func toolsMenuToolbarFavoritedToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToToolsListForToolbarItem(toolbarItem: .favoritedTools, animated: true)
    }
    
    func toolsMenuToolbarAllToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToToolsListForToolbarItem(toolbarItem: .allTools, animated: true)
    }
}
