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
    private let startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView
    
    private var lessonsView: LessonsListView?
    private var favoritedToolsView: FavoritedToolsView?
    private var allToolsView: AllToolsView?
    private var toolsListsViews: [UIView] = Array()
    private var isAnimatingNavigationToToolsList: Bool = false
    private var chooseLanguageButton: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
                
    @IBOutlet weak private var toolsListsScrollView: UIScrollView!
    @IBOutlet weak private var toolbarView: ToolsMenuToolbarView!
    @IBOutlet weak private var bottomView: UIView!
            
    required init(viewModel: ToolsMenuViewModelType, startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView) {
        
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
            action: #selector(handleMenu(barButtonItem:))
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
        
        let lessonsView: LessonsListView = LessonsListView(viewModel: viewModel.lessonsWillAppear())
        let favoritedToolsView: FavoritedToolsView = FavoritedToolsView(viewModel: viewModel.favoritedToolsWillAppear())
        let allToolsView: AllToolsView = AllToolsView(viewModel: viewModel.allToolsWillAppear())
        
        addToolsListView(toolsListView: lessonsView.view)
        addToolsListView(toolsListView: favoritedToolsView.view)
        addToolsListView(toolsListView: allToolsView.view)
        
        toolsListsScrollView.delegate = self
        
        toolbarView.configure(viewModel: viewModel.toolbarWillAppear(), delegate: self)
                
        favoritedToolsView.setDelegate(delegate: self)
        
        self.lessonsView = lessonsView
        self.favoritedToolsView = favoritedToolsView
        self.allToolsView = allToolsView
        
        navigateToToolsListForToolbarItem(toolbarItem: startingToolbarItem, animated: false)
    }
    
    
    func resetMenu() {
        
        if let lessonsView = lessonsView {
            lessonsView.scrollToTopOfLessons(animated: false)
        }
        
        if let favoritedToolsView = favoritedToolsView {
            favoritedToolsView.scrollToTopOfTools(animated: false)
        }
        
        if let allToolsView = allToolsView {
            allToolsView.scrollToTopOfTools(animated: false)
        }
        
        if toolsListsScrollView != nil {
            navigateToToolsListForToolbarItem(toolbarItem: startingToolbarItem, animated: false)
        }
    }
    
    @objc func handleMenu(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc func handleLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    private func navigateToToolsListForToolbarItem(toolbarItem: ToolsMenuToolbarView.ToolbarItemView, animated: Bool) {
        
        guard let page = toolbarView.toolbarItemViews.firstIndex(of: toolbarItem) else {
            return
        }
        
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
        
        if animated {
            isAnimatingNavigationToToolsList = true
        }
        
        toolsListsScrollView.setContentOffset(
            CGPoint(x: toolsListsBounds.size.width * CGFloat(page), y: 0),
            animated: animated
        )
        
        toolbarView.setSelectedToolbarItem(toolbarItem: toolbarItem)
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
                action: #selector(handleLanguage(barButtonItem:))
            )
        }
    }
    
    private var toolsListsBounds: CGRect {
        return toolsListsScrollView.bounds
    }
    
    private func addToolsListView(toolsListView: UIView) {
        
        let itemPosition: Int = toolsListsViews.count
        
        toolsListView.frame = CGRect(
            x: CGFloat(itemPosition) * toolsListsBounds.size.width,
            y: 0,
            width: toolsListsBounds.size.width,
            height: toolsListsBounds.size.height
        )
        
        toolsListsViews.append(toolsListView)
        
        toolsListsScrollView.addSubview(toolsListView)
        
        toolsListsScrollView.contentSize = CGSize(
            width: toolsListsBounds.size.width * CGFloat(toolsListsViews.count),
            height: toolsListsBounds.size.height
        )
    }
    
    private func getMostVisibleToolsList() -> ToolsMenuToolbarView.ToolbarItemView? {
        
        let mostVisibleItem: ToolsMenuToolbarView.ToolbarItemView?
        let middleContentOffset: CGFloat = toolsListsScrollView.contentOffset.x + (toolsListsBounds.size.width / 2)
        
        var mostVisiblePage: Int = Int(middleContentOffset / toolsListsBounds.size.width)
        
        if mostVisiblePage < 0 {
            mostVisiblePage = 0
        }
        else if mostVisiblePage >= toolbarView.toolbarItemViews.count {
            mostVisiblePage = toolbarView.toolbarItemViews.count - 1
        }
        
        if mostVisiblePage >= 0 && mostVisiblePage < toolbarView.toolbarItemViews.count {
            mostVisibleItem = toolbarView.toolbarItemViews[mostVisiblePage]
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
           !isAnimatingNavigationToToolsList,
           let mostVisibleItem = getMostVisibleToolsList() {
            
            toolbarView.setSelectedToolbarItem(toolbarItem: mostVisibleItem)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == toolsListsScrollView {
            isAnimatingNavigationToToolsList = false
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
