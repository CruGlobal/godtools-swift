//
//  OnboardingTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialView: UIViewController {
    
    private let viewModel: OnboardingTutorialViewModelType
    
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var footerView: UIView!
    @IBOutlet weak private var backgroundPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var showMoreButton: OnboardPrimaryButton!
    @IBOutlet weak private var getStartedButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    @IBOutlet weak private var continueButtonTop: NSLayoutConstraint!
    @IBOutlet weak private var showMoreButtonTop: NSLayoutConstraint!
    @IBOutlet weak private var getStartedButtonTop: NSLayoutConstraint!
    @IBOutlet weak private var footerAreaHeight: NSLayoutConstraint!
    
    required init(viewModel: OnboardingTutorialViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: OnboardingTutorialView.self), bundle: nil)
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
        showMoreButton.addTarget(self, action: #selector(handleShowMore(button:)), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(handleGetStarted(button:)), for: .touchUpInside)
        
        backgroundPagesView.delegate = self
        tutorialPagesView.delegate = self
    }
    
    private func setupLayout() {
        
        // backgroundPagesView
        backgroundPagesView.pageBackgroundColor = .white
        backgroundPagesView.registerPageCell(
            nib: UINib(nibName: OnboardingTutorialBackgroundCell.nibName, bundle: nil),
            cellReuseIdentifier: OnboardingTutorialBackgroundCell.reuseIdentifier
        )
        backgroundPagesView.gestureScrollingEnabled = false
        backgroundPagesView.isUserInteractionEnabled = false
        
        // tutorialPagesView
        tutorialPagesView.pageBackgroundColor = .clear
        tutorialPagesView.registerPageCell(
            nib: UINib(nibName: MainOnboardingTutorialCell.nibName, bundle: nil),
            cellReuseIdentifier: MainOnboardingTutorialCell.reuseIdentifier
        )
        tutorialPagesView.registerPageCell(
            nib: UINib(nibName: OnboardingTutorialUsageListCell.nibName, bundle: nil),
            cellReuseIdentifier: OnboardingTutorialUsageListCell.reuseIdentifier
        )
        
        //
        setTutorialButtonState(state: .continueButton, animated: false)
        
        //
        handleTutorialPageChange(page: 0)
    }
    
    private func setupBinding() {
        
        continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
        showMoreButton.setTitle(viewModel.showMoreButtonTitle, for: .normal)
        getStartedButton.setTitle(viewModel.getStartedButtonTitle, for: .normal)
        
        viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [OnboardingTutorialItem]) in
            self?.pageControl.numberOfPages = tutorialItems.count
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        backgroundPagesView.reloadData()
        tutorialPagesView.reloadData()
    }
    
    private func handleTutorialPageChange(page: Int) {
        
        pageControl.currentPage = page
        
        if tutorialPagesView.isOnLastPage {
            setSkipButton(hidden: true)
            setTutorialButtonState(state: .showMoreAndGetStarted, animated: true)
        }
        else {
            setSkipButton(hidden: false)
            setTutorialButtonState(state: .continueButton, animated: true)
        }
    }
    
    private func setSkipButton(hidden: Bool) {
        
        let skipButtonPosition: ButtonItemPosition = .right
        
        if skipButton == nil && !hidden {
            skipButton = addBarButtonItem(
                to: skipButtonPosition,
                title: viewModel.skipButtonTitle,
                style: .plain,
                color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                target: self,
                action: #selector(handleSkip(barButtonItem:))
            )
        }
        else if let skipButton = skipButton {
            hidden ? removeBarButtonItem(item: skipButton, barPosition: skipButtonPosition) : addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
        }
    }
    
    private func setTutorialButtonState(state: OnboardingTutorialButtonState, animated: Bool) {
        
        let layoutView: UIView = footerView
        let animationDuration: TimeInterval = 0.28
        let safeAreaHeight: CGFloat = 50
        let hidden: CGFloat = footerAreaHeight.constant + safeAreaHeight
        let visible: CGFloat = 0
        
        switch state {
            
        case .continueButton:
            showMoreButtonTop.constant = hidden
            getStartedButtonTop.constant = hidden
            if animated {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    layoutView.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    self.showMoreButton.alpha = 0
                    self.getStartedButton.alpha = 0
                })
            }
            else {
                showMoreButton.alpha = 0
                getStartedButton.alpha = 0
                layoutView.layoutIfNeeded()
            }
            
            continueButtonTop.constant = visible
            continueButton.alpha = 1
            if animated {
                UIView.animate(withDuration: animationDuration, delay: 0.14, options: .curveEaseOut, animations: {
                    layoutView.layoutIfNeeded()
                }, completion: nil)
            }
            else {
                layoutView.layoutIfNeeded()
            }
                                
        case .showMoreAndGetStarted:
            
            continueButtonTop.constant = hidden
            if animated {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    layoutView.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    self.continueButton.alpha = 0
                })
            }
            else {
                continueButton.alpha = 0
                layoutView.layoutIfNeeded()
            }
            
            showMoreButtonTop.constant = visible
            showMoreButton.alpha = 1
            getStartedButtonTop.constant = visible
            getStartedButton.alpha = 1
            if animated {
                UIView.animate(withDuration: animationDuration, delay: 0.14, options: .curveEaseOut, animations: {
                    layoutView.layoutIfNeeded()
                }, completion: nil)
            }
            else {
                layoutView.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        viewModel.skipTapped()
    }
    
    @objc func handlePageControlChanged() {
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue(button: UIButton) {
        tutorialPagesView.scrollToNextPage(animated: true)
        viewModel.continueTapped()
    }
    
    @objc func handleShowMore(button: UIButton) {
        viewModel.showMoreTapped()
    }
    
    @objc func handleGetStarted(button: UIButton) {
        viewModel.getStartedTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension OnboardingTutorialView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.tutorialItems.value.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if pageNavigation == backgroundPagesView {
            
            let cell: OnboardingTutorialBackgroundCell = backgroundPagesView.getReusablePageCell(
                cellReuseIdentifier: OnboardingTutorialBackgroundCell.reuseIdentifier,
                indexPath: indexPath) as! OnboardingTutorialBackgroundCell
            
            let tutorialItem: OnboardingTutorialItem = viewModel.tutorialItems.value[indexPath.item]
            let viewModel = OnboardingTutorialBackgroundCellViewModel(item: tutorialItem)
            cell.configure(viewModel: viewModel)
            
            return cell
        }
        else if pageNavigation == tutorialPagesView {
            
            let tutorialItem: OnboardingTutorialItem = viewModel.tutorialItems.value[indexPath.item]
            
            if let mainTutorialItem = tutorialItem as? MainOnboardingTutorialItem {
                
                let cell = tutorialPagesView.getReusablePageCell(
                    cellReuseIdentifier: MainOnboardingTutorialCell.reuseIdentifier,
                    indexPath: indexPath) as! MainOnboardingTutorialCell
                    
                let viewModel = MainOnboardingTutorialCellViewModel(item: mainTutorialItem)
                cell.configure(viewModel: viewModel)
                
                return cell
            }
            else if let usageListItem = tutorialItem as? OnboardingTutorialUsageListItem {
                
                let cell = tutorialPagesView.getReusablePageCell(
                    cellReuseIdentifier: OnboardingTutorialUsageListCell.reuseIdentifier,
                    indexPath: indexPath) as! OnboardingTutorialUsageListCell
                           
                cell.configure(viewModel: OnboardingTutorialUsageListCellViewModel(usageListItem: usageListItem))
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        if pageNavigation == tutorialPagesView {
            
            handleTutorialPageChange(page: page)
            
            viewModel.pageDidChange(page: page)
        }
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        if pageNavigation == tutorialPagesView {
           
            pageControl.currentPage = page
            
            viewModel.pageDidAppear(page: page)
        }
    }
    
    func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        if pageNavigation == tutorialPagesView {
            backgroundPagesView.pagesCollectionView.setContentOffset(tutorialPagesView.pagesCollectionView.contentOffset, animated: false)
        }
    }
}
