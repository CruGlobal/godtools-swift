//
//  LessonPageView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol LessonPageViewDelegate: AnyObject {
    
    func lessonPageCloseLessonTapped(lessonPage: LessonPageView)
}

class LessonPageView: MobileContentPageView {
    
    private let viewModel: LessonPageViewModelType
    private let safeArea: UIEdgeInsets
    
    private var contentView: MobileContentStackView?
    
    private weak var delegate: LessonPageViewDelegate?
    
    @IBOutlet weak private var topInset: UIView!
    @IBOutlet weak private var contentContainerView: UIView!
    @IBOutlet weak private var bottomInset: UIView!
    
    @IBOutlet weak private var topInsetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomInsetBottomConstraint: NSLayoutConstraint!
    
    required init(viewModel: LessonPageViewModelType, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(viewModel: viewModel, nibName: String(describing: LessonPageView.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentPageViewModelType, nibName: String?) {
        fatalError("init(viewModel:nibName:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        topInsetTopConstraint.constant = safeArea.top
        bottomInsetBottomConstraint.constant = safeArea.bottom
        
        // topInset
        topInset.backgroundColor = .clear
        topInset.isUserInteractionEnabled = false
        
        // bottomInset
        bottomInset.backgroundColor = .clear
        bottomInset.isUserInteractionEnabled = false
        
        // contentContainerView
        contentContainerView.backgroundColor = .clear
    }
    
    override func setupBinding() {
        super.setupBinding()
        
    }
    
    func setLessonPageDelegate(delegate: LessonPageViewDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let contentView = childView as? MobileContentStackView {
            addContentView(contentView: contentView)
        }
    }
    
    override func didReceiveEvents(eventIds: [EventId]) {
        
        super.didReceiveEvents(eventIds: eventIds)
        
        for eventId in eventIds {
            if viewModel.manifestDismissListeners.contains(eventId) {
                delegate?.lessonPageCloseLessonTapped(lessonPage: self)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        viewModel.pageDidAppear()
    }
}

// MARK: - ContentView

extension LessonPageView {
    
    private func addContentView(contentView: MobileContentStackView) {
        
        guard self.contentView == nil else {
            return
        }
        
        contentContainerView.isHidden = false
        
        contentContainerView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.constrainEdgesToView(view: contentContainerView)
        
        self.contentView = contentView        
    }
}
