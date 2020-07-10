//
//  TractView.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TractView: UIViewController {
        
    private let viewModel: TractViewModelType
            
    private var didLayoutSubviews: Bool = false
    private var didAddObservers: Bool = false
           
    private weak var languageControl: UISegmentedControl?
    
    @IBOutlet weak private var tractPagesCollectionView: UICollectionView!
    
    required init(viewModel: TractViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: TractView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        UIApplication.shared.isIdleTimerDisabled = false
        // TODO: Find out what TractBindings does. ~Levi
        TractBindings.clearAllBindings()
        removeObservers()
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
        
        languageControl?.addTarget(
            self,
            action: #selector(didChooseLanguage(segmentedControl:)),
            for: .valueChanged
        )
        
        UIApplication.shared.isIdleTimerDisabled = true
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
            tractPagesCollectionView.delegate = self
            tractPagesCollectionView.dataSource = self
            
            viewModel.tractXmlPageItems.addObserver(self) { [weak self] (tractPageItems: [TractXmlPageItem]) in
                self?.tractPagesCollectionView.reloadData()
            }
            
            viewModel.currentTractPageItemIndex.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Int>) in
                
                if let tractPagesCollectionView = self?.tractPagesCollectionView {
                    let numberOfItems: Int = tractPagesCollectionView.numberOfItems(inSection: 0)
                    if numberOfItems > 0 {
                        tractPagesCollectionView.scrollToItem(
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
        
        tractPagesCollectionView.register(
            UINib(nibName: TractPageCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: TractPageCell.reuseIdentifier
        )
        tractPagesCollectionView.isScrollEnabled = true
        tractPagesCollectionView.isPagingEnabled = true
        tractPagesCollectionView.showsVerticalScrollIndicator = false
        tractPagesCollectionView.showsHorizontalScrollIndicator = false
        tractPagesCollectionView.contentInset = UIEdgeInsets.zero
        automaticallyAdjustsScrollViewInsets = false
        if viewModel.isRightToLeftLanguage {
            tractPagesCollectionView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (title: String) in
            self?.title = title
        }
        
        viewModel.selectedTractLanguage.addObserver(self) { [weak self] (tractLanguage: TractLanguage) in
            
            switch tractLanguage.languageType {
            case .primary:
                self?.languageControl?.selectedSegmentIndex = 0
            case .parallel:
                self?.languageControl?.selectedSegmentIndex = 1
            }
            
            self?.tractPagesCollectionView.reloadData()
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
        
        if !viewModel.hidesChooseLanguageControl && languageControl == nil {
                
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
            
            navigationItem.titleView = chooseLanguageControl
            
            languageControl = chooseLanguageControl
        }
    }
    
    private func removeObservers() {
        
        if didAddObservers {
            didAddObservers = false
            
            NotificationCenter.default.removeObserver(self, name: .moveToPageNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .moveToNextPageNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .moveToPreviousPageNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .sendEmailFromTractForm, object: nil)
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
    
    @objc func sendEmail(notification: Notification) {
        
        let dictionary: [AnyHashable: Any] = notification.userInfo ?? [:]
        
        viewModel.sendEmailTapped(
            subject: dictionary["subject"] as? String,
            message: dictionary["content"] as? String,
            isHtml: dictionary["html"] as? Bool
        )
    }
}

extension TractView: BaseTractElementDelegate {
    
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func displayedLanguage() -> LanguageModel? {
        
        // TODO: Why is this method needed here? ~Levi
        
        return viewModel.selectedTractLanguage.value.language
    }
}

extension TractView {
    
    // TODO: Need to find out what this is for. ~Levi
    func loadPagesIds() {
        var counter = 0
        for page in viewModel.primaryTractPages {
            guard let pageListeners = page.pageListeners() else { continue }
            for listener in pageListeners {
                TractBindings.addPageBinding(listener, counter)
            }
            
            counter += 1
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension TractView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tractXmlPageItems.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TractPageCell = tractPagesCollectionView.dequeueReusableCell(
            withReuseIdentifier: TractPageCell.reuseIdentifier,
            for: indexPath) as! TractPageCell
                
        let tractPage: TractPage? = viewModel.getTractPage(page: indexPath.item)
                
        tractPage?.setDelegate(self)

        if let tractPage = tractPage {
            cell.setTractPage(tractPage: tractPage)
        }
                                        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
               
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return tractPagesCollectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIScrollViewDelegate

extension TractView: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tractPagesCollectionView {
            if !decelerate {
                handleDidScrollToItemInTractPagesCollectionView()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tractPagesCollectionView {
            handleDidScrollToItemInTractPagesCollectionView()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == tractPagesCollectionView {
            handleDidScrollToItemInTractPagesCollectionView()
        }
    }
    
    private func handleDidScrollToItemInTractPagesCollectionView() {
        
        tractPagesCollectionView.layoutIfNeeded()
        
        if let visibleCell = tractPagesCollectionView.visibleCells.first {
            if let indexPath = tractPagesCollectionView.indexPath(for: visibleCell) {
                viewModel.didScrollToTractPage(page: indexPath.item)
            }
        }
    }
}
