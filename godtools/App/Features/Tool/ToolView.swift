//
//  ToolView.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolView: UIViewController {
    
    private let viewModel: ToolViewModelType
    private let navBarView: ToolNavBarView = ToolNavBarView()
    
    private var safeArea: UIEdgeInsets?
    private var didLayoutSubviews: Bool = false
            
    @IBOutlet weak private var toolPagesView: PageNavigationCollectionView!
    
    required init(viewModel: ToolViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ToolView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        viewModel.viewLoaded()
                
        toolPagesView.delegate = self
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true

        viewModel.currentPage.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Int>) in
            self?.toolPagesView.scrollToPage(page: animatableValue.value, animated: animatableValue.animated)
        }
        
        let safeAreaTopInset: CGFloat
        let safeAreaBottomInset: CGFloat
        
        if #available(iOS 11.0, *) {
            safeAreaTopInset = view.safeAreaInsets.top
            safeAreaBottomInset = view.safeAreaInsets.bottom
        } else {
            safeAreaTopInset = topLayoutGuide.length
            safeAreaBottomInset = bottomLayoutGuide.length
        }
        
        safeArea = UIEdgeInsets(top: safeAreaTopInset, left: 0, bottom: safeAreaBottomInset, right: 0)
        
        toolPagesView.reloadData()
    }
    
    private func setupLayout() {
                
        // toolPagesView
        toolPagesView.pageBackgroundColor = .clear
        toolPagesView.registerPageCell(
            nib: UINib(nibName: ToolPageCell.nibName, bundle: nil),
            cellReuseIdentifier: ToolPageCell.reuseIdentifier
        )
        toolPagesView.pagesCollectionView.contentInset = UIEdgeInsets.zero
        toolPagesView.pagesCollectionView.semanticContentAttribute = viewModel.toolPageNavigationSemanticContentAttribute
        
        if #available(iOS 11.0, *) {
            toolPagesView.pagesCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func setupBinding() {
                        
        navBarView.configure(parentViewController: self, viewModel: viewModel.navBarWillAppear())
        
        viewModel.numberOfToolPages.addObserver(self) { [weak self] (numberOfToolPages: Int) in
            self?.toolPagesView.reloadData()
        }
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension ToolView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        
        return viewModel.numberOfToolPages.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ToolPageCell = toolPagesView.getReusablePageCell(
            cellReuseIdentifier: ToolPageCell.reuseIdentifier,
            indexPath: indexPath) as! ToolPageCell
        
        if let toolPageViewModel = viewModel.toolPageWillAppear(page: indexPath.row), let safeArea = self.safeArea {
                        
            cell.configure(
                viewModel: toolPageViewModel,
                windowViewController: navigationController ?? self,
                safeArea: safeArea
            )            
        }
        
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        view.endEditing(true)
        
        viewModel.toolPageDidChange(page: page)
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        viewModel.toolPageDidAppear(page: page)
        
        if let toolPageCell = pageCell as? ToolPageCell {
            toolPageCell.pageDidAppear()
        }
    }
    
    func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
        if let toolPageCell = pageCell as? ToolPageCell {
            toolPageCell.pageDidDisappear()
        }
    }
}
