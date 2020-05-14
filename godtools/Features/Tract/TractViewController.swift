//
//  TractViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash
import MessageUI
import PromiseKit

class TractViewController: UIViewController {
        
    private let viewModel: TractViewModelType
        
    // TODO: Need this for now to keep tractPages in memory. ~Levi
    private var tractPages: [Int: TractPage] = Dictionary()
    
    private var didLayoutSubviews: Bool = false
    private var didAddObservers: Bool = false
           
    @IBOutlet weak private var toolPagesCollectionView: UICollectionView!
    
    required init(viewModel: TractViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "TractViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        UIApplication.shared.isIdleTimerDisabled = false
        // TODO: Find out what TractBindings does. ~Levi
        TractBindings.clearAllBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        viewModel.viewLoaded()
        
        // TODO: Need to find out what this does. ~Levi
        TractBindings.setupBindings()

        loadPagesIds()
        
        addObservers()
        
        _ = addBarButtonItem(
            to: .left,
            image: ImageCatalog.navHome.image,
            color: viewModel.navBarAttributes.navBarControlColor,
            target: self,
            action: #selector(handleHome(barButtonItem:))
        )
        
        _ = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navShare.image,
            color: viewModel.navBarAttributes.navBarControlColor,
            target: self,
            action: #selector(handleShare(barButtonItem:))
        )
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        for translation in viewModel.resource.translations {
            if let languageCode = translation.language?.code {
                if languageCode.contains("en") {
                    print("translation id: \(translation.remoteId)")
                    print("  language code: \(languageCode)")
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            let navigationBarHeight: CGFloat = navigationController?.navigationBar.frame.size.height ?? 50
            // TODO: Eventually I'd like to do something different here rather than set a global on TractPage.
            // Instead tool pages can have a contentInset top, bottom to move content in which can be injected. ~Levi
            TractPage.navbarHeight = navigationBarHeight
               
            // NOTE: Waiting for view to finish laying out in order for the collection sizeForItem to return the correct bounds size.
            toolPagesCollectionView.delegate = self
            toolPagesCollectionView.dataSource = self
            
            viewModel.currentToolPageItemIndex.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Int>) in
                
                if let toolPagesCollectionView = self?.toolPagesCollectionView {
                    let numberOfItems: Int = toolPagesCollectionView.numberOfItems(inSection: 0)
                    if numberOfItems > 0 {
                        toolPagesCollectionView.scrollToItem(
                            at: IndexPath(item: animatableValue.value, section: 0),
                            at: .centeredHorizontally,
                            animated: animatableValue.animated
                        )
                    }
                }
            }
        }
    }
    
    private func setupLayout() {
        
        view.backgroundColor = viewModel.navBarAttributes.navBarColor
        
        setupNavigationBar()
        
        setupChooseLanguageControl()
        
        toolPagesCollectionView.register(
            UINib(nibName: ToolPageCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: ToolPageCell.reuseIdentifier
        )
        toolPagesCollectionView.isScrollEnabled = true
        toolPagesCollectionView.isPagingEnabled = true
        toolPagesCollectionView.showsVerticalScrollIndicator = false
        toolPagesCollectionView.showsHorizontalScrollIndicator = false
        toolPagesCollectionView.contentInset = UIEdgeInsets.zero
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (title: String) in
            self?.title = title
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
    
    private func setupNavigationBar() {
        
        let navBarColor: UIColor = viewModel.navBarAttributes.navBarColor
        let navBarControlColor: UIColor = viewModel.navBarAttributes.navBarControlColor
                    
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.setBackgroundImage(NavigationBarBackground.createFrom(navBarColor), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: navBarControlColor,
            NSAttributedString.Key.font: UIFont.gtSemiBold(size: 17.0)
        ]
        
        navigationController?.navigationBar.tintColor = navBarControlColor
    }
    
    private func setupChooseLanguageControl() {
        
        if !viewModel.hidesChooseLanguageControl {
                
            let navBarColor: UIColor = viewModel.navBarAttributes.navBarColor
            let navBarControlColor: UIColor = viewModel.navBarAttributes.navBarControlColor
            let chooseLanguageControl: UISegmentedControl = UISegmentedControl()
            
            chooseLanguageControl.insertSegment(
                withTitle: viewModel.chooseLanguageControlPrimaryLanguageTitle,
                at: 0,
                animated: false
            )
            chooseLanguageControl.insertSegment(
                withTitle: viewModel.chooseLanguageControlParallelLanguageTitle,
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
            
            chooseLanguageControl.addTarget(
                self,
                action: #selector(didChooseLanguage(segmentedControl:)),
                for: .valueChanged
            )
            
            navigationItem.titleView = chooseLanguageControl
        }
    }
    
    private func addObservers() {
                
        if !didAddObservers {
            didAddObservers = true
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(moveToPage),
                                                   name: .moveToPageNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(moveToNextPage),
                                                   name: .moveToNextPageNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(moveToPreviousPage),
                                                   name: .moveToPreviousPageNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(sendEmail),
                                                   name: .sendEmailFromTractForm,
                                                   object: nil)
        }
    }
    
    @objc func moveToPage(notification: Notification) {
        
        guard let dictionary = notification.userInfo as? [String: String] else {
            return
        }
        
        guard let pageListener = dictionary["pageListener"] else { return }
        guard let page = TractBindings.pageBindings[pageListener] else { return }
        
        viewModel.navigateToPageTapped(page: page)
    }
    
    @objc func moveToNextPage() {
        viewModel.navigateToNextPageTapped()
    }
    
    @objc func moveToPreviousPage() {
        viewModel.navigateToPreviousPageTapped()
    }
}

extension TractViewController: BaseTractElementDelegate {
    
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func displayedLanguage() -> Language? {
        
        // TODO: Why is this method needed here? ~Levi
        
        return viewModel.selectedLanguage.value
    }
}

extension TractViewController {
    
    // TODO: Need to findout what this is for. ~Levi
    func loadPagesIds() {
        var counter = 0
        for page in viewModel.toolXmlPages.value {
            guard let pageListeners = page.pageListeners() else { continue }
            for listener in pageListeners {
                TractBindings.addPageBinding(listener, counter)
            }
            
            counter += 1
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension TractViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.toolXmlPages.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ToolPageCell = toolPagesCollectionView.dequeueReusableCell(
            withReuseIdentifier: ToolPageCell.reuseIdentifier,
            for: indexPath) as! ToolPageCell
                
        let pageParentView: UIView = cell.contentView
        
        for subview in pageParentView.subviews {
            subview.removeFromSuperview()
        }
        
        let toolXmlPage: XMLPage = viewModel.toolXmlPages.value[indexPath.row]
                
        let configurations = TractConfigurations()
        configurations.defaultTextAlignment = .left
        configurations.pagination = toolXmlPage.pagination
        configurations.language = viewModel.selectedLanguage.value
        configurations.resource = viewModel.resource
                
        let tractPage = TractPage(
            startWithData: toolXmlPage.pageContent(),
            height: toolPagesCollectionView.bounds.size.height,
            manifestProperties: viewModel.toolManifest,
            configurations: configurations,
            parallelElement: nil
        )
        
        tractPage.setDelegate(self)
        
        tractPages[indexPath.row] = tractPage
        
        pageParentView.addSubview(tractPage.renderedView)
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return toolPagesCollectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIScrollViewDelegate

extension TractViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == toolPagesCollectionView {
            if !decelerate {
                handleDidScrollToItemInToolPagesCollectionView()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == toolPagesCollectionView {
            handleDidScrollToItemInToolPagesCollectionView()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == toolPagesCollectionView {
            handleDidScrollToItemInToolPagesCollectionView()
        }
    }
    
    private func handleDidScrollToItemInToolPagesCollectionView() {
        
        toolPagesCollectionView.layoutIfNeeded()
        
        if let visibleCell = toolPagesCollectionView.visibleCells.first {
            if let indexPath = toolPagesCollectionView.indexPath(for: visibleCell) {
                viewModel.didScrollToToolPage(index: indexPath.item)
            }
        }
    }
}
