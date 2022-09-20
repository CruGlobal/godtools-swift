//
//  TutorialPagerView.swift
//  godtools
//
//  Created by Robert Eldredge on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import YouTubeiOSPlayerHelper

class TutorialPagerView: UIViewController {
    
    private let viewModel: TutorialPagerViewModelType
    
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var footerView: UIView!
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    @IBOutlet weak private var continueButtonTop: NSLayoutConstraint!
    
    required init(viewModel: TutorialPagerViewModelType) {
        
        self.viewModel = viewModel
        super.init(nibName: String(describing: TutorialPagerView.self), bundle: nil)
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
        
        pageControl.addTarget(self, action: #selector(handlePageControlChanged), for: .valueChanged)
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        tutorialPagesView.delegate = self
    }
    
    private func setupLayout() {
        
        tutorialPagesView.pageBackgroundColor = .clear
        tutorialPagesView.registerPageCell(nib: UINib(nibName: TutorialCell.nibName, bundle: nil), cellReuseIdentifier: TutorialCell.reuseIdentifier)
    }
    
    private func setupBinding() {
        
        viewModel.pageCount.addObserver(self) { [weak self] (pageCount: Int) in
            self?.pageControl.currentPage = pageCount
            
            self?.reloadData()
        }
        
        viewModel.page.addObserver(self) { [weak self] (page: Int) in
            self?.pageControl.currentPage = page
        }
        
        
        viewModel.skipButtonHidden.addObserver(self) { [weak self] (hidden: Bool) in
            self?.setSkipButton(hidden: hidden)
        }
        
        viewModel.continueButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.continueButton.setTitle(title, for: .normal)
        }
        
        viewModel.continueButtonHidden.addObserver(self) { [weak self] (hidden: Bool) in
            self?.continueButton.isHidden = hidden
        }
    }
    
    private func reloadData() {
        
        tutorialPagesView.reloadData()
    }
    
    private func setSkipButton(hidden: Bool) {
        
        let skipButtonPosition: ButtonItemPosition = .right
        
        if skipButton == nil {
            if !hidden {
                skipButton = addBarButtonItem(
                    to: skipButtonPosition,
                    title: viewModel.skipButtonTitle,
                    style: .plain,
                    color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                    target: self,
                    action: #selector(handleSkip(barButtonItem:))
                )
            }
        }
        else if let skipButton = skipButton {
            hidden ? removeBarButtonItem(item: skipButton, barPosition: skipButtonPosition) : addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
        }
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        
        viewModel.skipTapped()
    }
    
    @objc func handlePageControlChanged() {
        
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue() {
        
        tutorialPagesView.scrollToNextPage(animated: true)
        
        viewModel.continueTapped()
    }
}

//MARK: -- PageNavigationCollectionViewDelegate

extension TutorialPagerView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.pageCount.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = tutorialPagesView.getReusablePageCell(cellReuseIdentifier: TutorialCell.reuseIdentifier, indexPath: indexPath) as! TutorialCell
        
        let cellViewModel = viewModel.tutorialItemWillAppear(index: indexPath.item)
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        if pageNavigation == tutorialPagesView {
                        
            viewModel.pageDidChange(page: page)
        }
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        if pageNavigation == tutorialPagesView {
            
            viewModel.pageDidAppear(page: page)
        }
    }
}
