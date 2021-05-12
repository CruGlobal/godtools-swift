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

    private var lessonsView: LessonsListView?
    private var favoritedToolsView: FavoritedToolsView?
    private var allToolsView: AllToolsView?
    private var chooseLanguageButton: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
                
    @IBOutlet weak private var toolsNavigationView: PageNavigationCollectionView!
    @IBOutlet weak private var toolbarView: ToolsMenuToolbarView!
    @IBOutlet weak private var bottomView: UIView!
            
    required init(viewModel: ToolsMenuViewModelType) {
        
        self.viewModel = viewModel
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

        // toolsNavigationView
        toolsNavigationView.registerPageCell(
            nib: UINib(nibName: ToolNavigationPageCell.nibName, bundle: nil),
            cellReuseIdentifier: ToolNavigationPageCell.reuseIdentifier
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
        
        lessonsView = LessonsListView(viewModel: viewModel.lessonsWillAppear())
        
        favoritedToolsView = FavoritedToolsView(viewModel: viewModel.favoritedToolsWillAppear())
        
        allToolsView = AllToolsView(viewModel: viewModel.allToolsWillAppear())
        
        toolbarView.configure(viewModel: viewModel.toolbarWillAppear(), delegate: self)
        
        toolsNavigationView.delegate = self
        
        favoritedToolsView?.setDelegate(delegate: self)
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
        
        toolsNavigationView.scrollToPage(page: 0, animated: false)
    }
    
    @objc func handleMenu(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc func handleLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    private func navigateToToolPageForToolbarItem(toolbarItem: ToolsMenuToolbarView.ToolbarItemView, animated: Bool) {
        
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
        
        toolsNavigationView.scrollToPage(
            page: page,
            animated: true
        )
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
}

// MARK: - PageNavigationCollectionViewDelegate

extension ToolsMenuView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return toolbarView.toolbarItemViews.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ToolNavigationPageCell = toolsNavigationView.getReusablePageCell(
            cellReuseIdentifier: ToolNavigationPageCell.reuseIdentifier,
            indexPath: indexPath) as! ToolNavigationPageCell
        
        let toolbarItemView = toolbarView.toolbarItemViews[indexPath.row]
        
        let toolsView: UIViewController?
        
        switch toolbarItemView {
        case .lessons:
            toolsView = lessonsView
            
        case .favoritedTools:
            toolsView = favoritedToolsView
            
        case .allTools:
            toolsView = allToolsView
        }
    
        if let toolsView = toolsView {
           cell.configure(pageViewController: toolsView, parentViewController: self)
        }
                
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        let toolbarItemView = toolbarView.toolbarItemViews[page]
        
        toolbarView.setSelectedToolbarItem(toolbarItem: toolbarItemView)
    }
}

// MARK: - FavoritedToolsViewDelegate

extension ToolsMenuView: FavoritedToolsViewDelegate {
    
    func favoritedToolsViewFindToolsTapped(favoritedToolsView: FavoritedToolsView) {
              
        navigateToToolPageForToolbarItem(toolbarItem: .allTools, animated: true)
    }
}

// MARK: - ToolsMenuToolbarViewDelegate

extension ToolsMenuView: ToolsMenuToolbarViewDelegate {
    
    func toolsMenuToolbarLessonsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToToolPageForToolbarItem(toolbarItem: .lessons, animated: true)
    }
    
    func toolsMenuToolbarFavoritedToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToToolPageForToolbarItem(toolbarItem: .favoritedTools, animated: true)
    }
    
    func toolsMenuToolbarAllToolsTapped(toolsMenuToolbar: ToolsMenuToolbarView) {
        
        navigateToToolPageForToolbarItem(toolbarItem: .allTools, animated: true)
    }
}
