//
//  TutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class TutorialView: UIViewController {
    
    private let viewModel: TutorialViewModelType
    
    private var backButton: UIBarButtonItem?
    private var closeButton: UIBarButtonItem?
    
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: TutorialViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: TutorialView.self), bundle: nil)
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
        setupBinding()
        
        closeButton = addBarButtonItem(
            to: .right,
            image: UIImage(named: "nav_item_close"),
            color: nil,
            target: self,
            action: #selector(handleClose(barButtonItem:))
        )
        
        pageControl.addTarget(self, action: #selector(handlePageControlChanged), for: .valueChanged)
        
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        // tutorialPagesView
        tutorialPagesView.registerPageCell(
            nib: UINib(nibName: TutorialCell.nibName, bundle: nil),
            cellReuseIdentifier: TutorialCell.reuseIdentifier
        )
        tutorialPagesView.delegate = self
    }
    
    private func setupBinding() {
        
        viewModel.hidesBackButton.addObserver(self) { [weak self] (hidden: Bool) in
            
            let backButtonPosition: ButtonItemPosition = .left
            
            if let view = self {
                if view.backButton == nil && !hidden {
                    view.backButton = view.addBarButtonItem(
                        to: backButtonPosition,
                        image: UIImage(named: "nav_item_back"),
                        color: nil,
                        target: self,
                        action: #selector(view.handleBack(barButtonItem:))
                    )
                }
                else if let backButton = view.backButton {
                    hidden ? view.removeBarButtonItem(item: backButton, barPosition: backButtonPosition) : view.addBarButtonItem(item: backButton, barPosition: backButtonPosition)
                }
            }
        }
        
        viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [TutorialItem]) in
            self?.pageControl.numberOfPages = tutorialItems.count
            self?.tutorialPagesView.reloadData()
        }
                
        viewModel.changePage.addObserver(self) { [weak self] (page: Int) in
            self?.tutorialPagesView.scrollToPage(page: page, animated: true)
        }
        
        viewModel.continueButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.continueButton.setTitle(title, for: .normal)
        }
    }
    
    @objc func handleBack(barButtonItem: UIBarButtonItem) {
        tutorialPagesView.scrollToPreviousPage(animated: true)
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeTapped()
    }
    
    @objc func handlePageControlChanged() {
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue(button: UIButton) {
        tutorialPagesView.scrollToNextPage(animated: true)
        viewModel.continueTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension TutorialView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.tutorialItems.value.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TutorialCell = tutorialPagesView.getReusablePageCell(
            cellReuseIdentifier: TutorialCell.reuseIdentifier,
            indexPath: indexPath) as! TutorialCell
        
        let tutorialItem: TutorialItem = viewModel.tutorialItems.value[indexPath.item]
        let cellViewModel = TutorialCellViewModel(
            item: tutorialItem,
            deviceLanguage: viewModel.deviceLanguage
        )
        
        cell.configure(viewModel: cellViewModel, delegate: self)
        
        return cell
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, willDisplay pageCell: UICollectionViewCell, forPageAt indexPath: IndexPath) {

    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, didEndDisplaying pageCell: UICollectionViewCell, forPageAt indexPath: IndexPath) {
        if let tutorialCell = pageCell as? TutorialCell {
            tutorialCell.stopVideo()
        }
    }
    
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int) {
        pageControl.currentPage = page
    }
    
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        pageControl.currentPage = page
        viewModel.pageDidAppear(page: page)
    }
}

// MARK: - TutorialCellDelegate

extension TutorialView: TutorialCellDelegate {
    func tutorialCellVideoPlayer(cell: TutorialCell, didChangeTo state: WKYTPlayerState) {
        if state == .playing {
            viewModel.tutorialVideoPlayTapped()
        }
    }
}
