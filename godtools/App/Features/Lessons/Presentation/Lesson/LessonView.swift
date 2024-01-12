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
        addProgressView(progressView: progressView)
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
        pageNavigationView.scrollToPreviousPage(animated: true)
    }
    
    @objc func nextPageButtonTapped() {
        pageNavigationView.scrollToNextPage(animated: true)
    }
}

// MARK: - LessonProgressViewDelegate

extension LessonView: LessonProgressViewDelegate {
    func lessonProgressViewCloseTapped(progressView: LessonProgressView) {
        viewModel.closeTapped()
    }
}

// MARK: - ProgressView

extension LessonView {
    
    private func addProgressView(progressView: LessonProgressView) {
        
        let parentView: UIView = view
        
        parentView.addSubview(progressView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .top,
            relatedBy: .equal,
            toItem: safeAreaView,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        parentView.addConstraint(leading)
        parentView.addConstraint(trailing)
        parentView.addConstraint(top)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: progressView.height
        )
        
        heightConstraint.priority = UILayoutPriority(1000)
        
        progressView.addConstraint(heightConstraint)
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
        
        let leading: NSLayoutConstraint
        let trailing: NSLayoutConstraint
        
        if layoutDirection == .forceRightToLeft {
            
            previousPageButton.setImage(ImageCatalog.lessonPageRightArrow.uiImage, for: .normal)
            nextPageButton.setImage(ImageCatalog.lessonPageLeftArrow.uiImage, for: .normal)
            
            leading = NSLayoutConstraint(
                item: nextPageButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
            
            trailing = NSLayoutConstraint(
                item: previousPageButton,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
        }
        else {
            
            previousPageButton.setImage(ImageCatalog.lessonPageLeftArrow.uiImage, for: .normal)
            nextPageButton.setImage(ImageCatalog.lessonPageRightArrow.uiImage, for: .normal)
            
            leading = NSLayoutConstraint(
                item: previousPageButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
            
            trailing = NSLayoutConstraint(
                item: nextPageButton,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
        }
        
        parentView.addConstraint(leading)
        parentView.addConstraint(trailing)
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
