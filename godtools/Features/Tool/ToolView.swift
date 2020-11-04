//
//  ToolView.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolView: UIViewController {
    
    enum RightNavbarPosition: Int {
        case shareMenu = 0
        case remoteShareActive = 1
    }
    
    private let viewModel: ToolViewModelType
    
    private var remoteShareActiveNavItem: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
    private var didAddObservers: Bool = false
           
    private weak var languageControl: UISegmentedControl?
            
    @IBOutlet weak private var toolPagesBackgroundView: PageNavigationCollectionView!
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
        
        toolPagesBackgroundView.delegate = self
        
        toolPagesView.delegate = self
        
        languageControl?.addTarget(
            self,
            action: #selector(didChooseLanguage(segmentedControl:)),
            for: .valueChanged
        )
        
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
    }
    
    private func setupLayout() {
        
        // toolPagesBackgroundView
        toolPagesBackgroundView.pageBackgroundColor = .clear
        toolPagesBackgroundView.registerPageCell(
            nib: UINib(nibName: ToolPageBackgroundCell.nibName, bundle: nil),
            cellReuseIdentifier: ToolPageBackgroundCell.reuseIdentifier
        )
        toolPagesBackgroundView.pagesCollectionView.contentInset = UIEdgeInsets.zero
        automaticallyAdjustsScrollViewInsets = false
        if viewModel.isRightToLeftLanguage {
            toolPagesBackgroundView.pagesCollectionView.semanticContentAttribute = .forceRightToLeft
        }
        
        // toolPagesView
        toolPagesView.pageBackgroundColor = .clear
        toolPagesView.registerPageCell(
            nib: UINib(nibName: ToolPageCell.nibName, bundle: nil),
            cellReuseIdentifier: ToolPageCell.reuseIdentifier
        )
        toolPagesView.pagesCollectionView.contentInset = UIEdgeInsets.zero
        automaticallyAdjustsScrollViewInsets = false
        if viewModel.isRightToLeftLanguage {
            toolPagesView.pagesCollectionView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    private func setupBinding() {
        
        setViewBackgroundColor(color: viewModel.navBarViewModel.navBarColor)
                
        configureNavigationBar(toolNavBarViewModel: viewModel.navBarViewModel)
        
        viewModel.remoteShareIsActive.addObserver(self) { [weak self] (isActive: Bool) in
            
            self?.setRemoteShareActiveNavItem(hidden: !isActive)
        }
        
        viewModel.selectedTractLanguage.addObserver(self) { [weak self] (tractLanguage: TractLanguage) in
            
            switch tractLanguage.languageType {
            case .primary:
                self?.languageControl?.selectedSegmentIndex = 0
            case .parallel:
                self?.languageControl?.selectedSegmentIndex = 1
            }
            
            self?.toolPagesView.reloadData()
        }
        
        viewModel.tractXmlPageItems.addObserver(self) { [weak self] (tractPageItems: [TractXmlPageItem]) in
            self?.toolPagesView.reloadData()
        }
        
        viewModel.numberOfToolPages.addObserver(self) { [weak self] (numberOfToolPages: Int) in
            self?.toolPagesView.reloadData()
        }
    }
    
    @objc func handleHome(barButtonItem: UIBarButtonItem) {
        viewModel.navHomeTapped()
    }
    
    @objc func handleShare(barButtonItem: UIBarButtonItem) {
        viewModel.shareTapped()
    }
    
    @objc func didChooseLanguage(segmentedControl: UISegmentedControl) {
        
        let segmentIndex: Int = segmentedControl.selectedSegmentIndex
        
        if segmentIndex == 0 {
            viewModel.primaryLanguageTapped()
        }
        else if segmentIndex == 1 {
            viewModel.parallelLanguagedTapped()
        }
    }
    
    private func setViewBackgroundColor(color: UIColor) {
        view.backgroundColor = .white
        toolPagesBackgroundView.backgroundColor = color
    }
    
    private func configureNavigationBar(toolNavBarViewModel: ToolNavBarViewModel) {
        
        title = toolNavBarViewModel.navTitle
        
        let navBarColor: UIColor = toolNavBarViewModel.navBarColor
        let navBarControlColor: UIColor = toolNavBarViewModel.navBarControlColor
                    
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.tintColor = navBarControlColor
        navigationController?.navigationBar.setBackgroundImage(NavigationBarBackground.createFrom(navBarColor), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: navBarControlColor,
            NSAttributedString.Key.font: UIFont.gtSemiBold(size: 17.0)
        ]
        
        _ = addBarButtonItem(
            to: .left,
            image: ImageCatalog.navHome.image,
            color: navBarControlColor,
            target: self,
            action: #selector(handleHome(barButtonItem:))
        )
        
        _ = addBarButtonItem(
            to: .right,
            index: RightNavbarPosition.shareMenu.rawValue,
            image: ImageCatalog.navShare.image,
            color: navBarControlColor,
            target: self,
            action: #selector(handleShare(barButtonItem:))
        )
        
        if !toolNavBarViewModel.hidesChooseLanguageControl && languageControl == nil {
                
            let navBarColor: UIColor = navBarColor
            let navBarControlColor: UIColor = navBarControlColor
            let chooseLanguageControl: UISegmentedControl = UISegmentedControl()
            
            chooseLanguageControl.insertSegment(
                withTitle: toolNavBarViewModel.chooseLanguageControlPrimaryLanguageTitle,
                at: 0,
                animated: false
            )
            chooseLanguageControl.insertSegment(
                withTitle: toolNavBarViewModel.chooseLanguageControlParallelLanguageTitle,
                at: 1,
                animated: false
            )
            
            chooseLanguageControl.selectedSegmentIndex = 0

            let font = UIFont.defaultFont(size: 14, weight: nil)
            if #available(iOS 13.0, *) {
                chooseLanguageControl.selectedSegmentTintColor = navBarControlColor
                chooseLanguageControl.layer.borderColor = navBarControlColor.cgColor
                chooseLanguageControl.layer.borderWidth = 1
                chooseLanguageControl.backgroundColor = .clear
            } else {
                // Fallback on earlier versions
            }
            
            chooseLanguageControl.setTitleTextAttributes([.font: font, .foregroundColor: navBarControlColor], for: .normal)
            chooseLanguageControl.setTitleTextAttributes([.font: font, .foregroundColor: navBarColor.withAlphaComponent(1)], for: .selected)
            
            navigationItem.titleView = chooseLanguageControl
            
            languageControl = chooseLanguageControl
        }
    }
    
    private func setRemoteShareActiveNavItem(hidden: Bool) {
        
        let position: ButtonItemPosition = .right
        
        if hidden, let remoteShareActiveNavItem = remoteShareActiveNavItem {
            removeBarButtonItem(item: remoteShareActiveNavItem, barPosition: position)
            self.remoteShareActiveNavItem = nil
        }
        else if !hidden && remoteShareActiveNavItem == nil {
            
            remoteShareActiveNavItem = addBarButtonItem(
                to: .right,
                index: RightNavbarPosition.remoteShareActive.rawValue,
                image: ImageCatalog.shareToolRemoteSessionActive.image,
                color: .white,
                target: nil,
                action: nil
            )
        }
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension ToolView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfToolPages.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if pageNavigation == toolPagesBackgroundView {
            
            let cell: ToolPageBackgroundCell = toolPagesBackgroundView.getReusablePageCell(
                cellReuseIdentifier: ToolPageBackgroundCell.reuseIdentifier,
                indexPath: indexPath) as! ToolPageBackgroundCell
            
            let cellViewModel: ToolBackgroundCellViewModel = viewModel.toolPageBackgroundWillAppear(page: indexPath.row)
            
            cell.configure(viewModel: cellViewModel)
            
            return cell
        }
        else if pageNavigation == toolPagesView {
            
            let cell: ToolPageCell = toolPagesView.getReusablePageCell(
                cellReuseIdentifier: ToolPageCell.reuseIdentifier,
                indexPath: indexPath) as! ToolPageCell
            
            let cellViewModel: ToolPageViewModelType? = viewModel.toolPageWillAppear(page: indexPath.row)
            
            if let cellViewModel = cellViewModel {
                cell.configure(viewModel: cellViewModel)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
        if pageNavigation == toolPagesView {
            viewModel.toolPageDidChange(page: page)
        }
    }
    
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
        if pageNavigation == toolPagesView {
            viewModel.toolPageDidAppear(page: page)
        }
    }
    
    func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView) {
        if pageNavigation == toolPagesView {
            toolPagesBackgroundView.pagesCollectionView.setContentOffset(toolPagesView.pagesCollectionView.contentOffset, animated: false)
        }
    }
}
