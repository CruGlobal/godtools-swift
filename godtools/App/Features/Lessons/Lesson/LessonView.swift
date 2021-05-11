//
//  LessonView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonView: MobileContentPagesView {
    
    private let viewModel: LessonViewModelType
    private let progressView: LessonProgressView = LessonProgressView()
                        
    required init(viewModel: LessonViewModelType) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
        
        progressView.setDelegate(delegate: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentPagesViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        // pageInsets
        setPageInsets(pageInsets: UIEdgeInsets(top: progressView.height, left: 0, bottom: 0, right: 0))
        
        // navigationController
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // progressView
        addProgressView(progressView: progressView)
        progressView.setProgress(progress: 0, animated: false)
    }
    
    override func setupBinding() {
        super.setupBinding()
        
        viewModel.progress.addObserver(self) { [weak self] (progress: AnimatableValue<CGFloat>) in
            self?.progressView.setProgress(progress: progress.value, animated: progress.animated)
        }
    }
    
    override func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        super.pageNavigationPageDidAppear(pageNavigation: pageNavigation, pageCell: pageCell, page: page)
        viewModel.lessonPageDidAppear(page: page)
    }
    
    override func didConfigurePageView(pageView: MobileContentPageView) {
        super.didConfigurePageView(pageView: pageView)
        
        if let lessonPage = pageView as? LessonPageView {
            lessonPage.setLessonPageDelegate(delegate: self)
        }
    }
}

// MARK: - LessonPageViewDelegate

extension LessonView: LessonPageViewDelegate {
    func lessonPageCloseLessonTapped(lessonPage: LessonPageView) {
        viewModel.closeTapped()
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
