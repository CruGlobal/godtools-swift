//
//  LessonView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonView: MobileContentPagesView {
    
    private let viewModel: LessonViewModel
    private let progressView: LessonProgressView
    private let previousPageButton: UIButton = UIButton(type: .custom)
    private let nextPageButton: UIButton = UIButton(type: .custom)
    
    init(viewModel: LessonViewModel, navigationBar: AppNavigationBar?) {
        
        self.viewModel = viewModel
        self.progressView = LessonProgressView(layoutDirection: viewModel.layoutDirection)
        
        super.init(viewModel: viewModel, navigationBar: navigationBar)
        
        progressView.setDelegate(delegate: self)
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
        
        previousPageButton.addTarget(self, action: #selector(previousPageButtonTapped), for: .touchUpInside)
        nextPageButton.addTarget(self, action: #selector(nextPageButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        // pageInsets
        setPageInsets(pageInsets: UIEdgeInsets(top: progressView.height, left: 0, bottom: 0, right: 0))
        
        // progressView
        progressView.attachToParent(viewController: self, safeAreaView: safeAreaView)
        progressView.setProgress(progress: 0, animated: false)
        
        // navigation buttons
        addNavigationButtons()
    }
    
    override func setupBinding() {
        super.setupBinding()
        
        viewModel.progress.addObserver(self) { [weak self] (progress: AnimatableValue<CGFloat>) in
            self?.progressView.setProgress(progress: progress.value, animated: progress.animated)
        }
    }
    
    override func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        super.pageNavigationDidChangeMostVisiblePage(pageNavigation: pageNavigation, pageCell: pageCell, page: page)
        viewModel.lessonMostVisiblePageDidChange(page: page)
    }
    
    @objc func previousPageButtonTapped() {
        viewModel.navigateToPreviousPage(animated: true)
    }
    
    @objc func nextPageButtonTapped() {
        viewModel.navigateToNextPage(animated: true)
    }
}

// MARK: - LessonProgressViewDelegate

extension LessonView: LessonProgressViewDelegate {
    func lessonProgressViewCloseTapped(progressView: LessonProgressView) {
        viewModel.closeTapped()
    }
}

// MARK: - Navigation Buttons

extension LessonView {
    
    private var navigationButtonSize: CGSize {
        return CGSize(width: 34, height: 44)
    }
    
    private func addNavigationButtons() {
        
        guard previousPageButton.superview == nil && nextPageButton.superview == nil else {
            return
        }
                
        let parentView: UIView = view
        let layoutDirection: UISemanticContentAttribute = viewModel.layoutDirection
        
        parentView.addSubview(previousPageButton)
        parentView.addSubview(nextPageButton)
        
        previousPageButton.translatesAutoresizingMaskIntoConstraints = false
        nextPageButton.translatesAutoresizingMaskIntoConstraints = false
        
        addNavigationButtonSizeConstraints(button: previousPageButton)
        addNavigationButtonSizeConstraints(button: nextPageButton)
        
        addNavigationButtonBottomConstraints(button: previousPageButton, parentView: parentView)
        addNavigationButtonBottomConstraints(button: nextPageButton, parentView: parentView)
        
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
        
        if layoutDirection == .forceRightToLeft {
            
            previousPageButton.setImage(ImageCatalog.lessonPageRightArrow.uiImage, for: .normal)
            nextPageButton.setImage(ImageCatalog.lessonPageLeftArrow.uiImage, for: .normal)
            
            left = NSLayoutConstraint(
                item: nextPageButton,
                attribute: .left,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .left,
                multiplier: 1,
                constant: 0
            )
            
            right = NSLayoutConstraint(
                item: previousPageButton,
                attribute: .right,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .right,
                multiplier: 1,
                constant: 0
            )
        }
        else {
            
            previousPageButton.setImage(ImageCatalog.lessonPageLeftArrow.uiImage, for: .normal)
            nextPageButton.setImage(ImageCatalog.lessonPageRightArrow.uiImage, for: .normal)
            
            left = NSLayoutConstraint(
                item: previousPageButton,
                attribute: .left,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .left,
                multiplier: 1,
                constant: 0
            )
            
            right = NSLayoutConstraint(
                item: nextPageButton,
                attribute: .right,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .right,
                multiplier: 1,
                constant: 0
            )
        }
        
        parentView.addConstraint(left)
        parentView.addConstraint(right)
    }
    
    private func addNavigationButtonSizeConstraints(button: UIButton) {
        
        let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: button,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: navigationButtonSize.width
        )
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: button,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: navigationButtonSize.height
        )
        
        widthConstraint.priority = UILayoutPriority(1000)
        heightConstraint.priority = UILayoutPriority(1000)
        
        button.addConstraint(widthConstraint)
        button.addConstraint(heightConstraint)
    }
    
    private func addNavigationButtonBottomConstraints(button: UIButton, parentView: UIView) {
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: button,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: safeAreaView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        parentView.addConstraint(bottom)
    }
}
