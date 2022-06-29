//
//  FavoritedToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class FavoritedToolsView: UIHostingController<FavoritesContentView>, ToolsMenuPageView {
    
    private let contentView: FavoritesContentView
    
    required init(contentView: FavoritesContentView) {
        
        self.contentView = contentView
        
        super.init(rootView: contentView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // TODO: - GT-1643: make tutorial work in SwiftUI
//    @IBOutlet weak private var openTutorialTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
    }
    
    private func setupBinding() {
                
        // TODO: - GT-1643: tutorial
//        let openTutorialViewModel = viewModel.openTutorialWillAppear()
//        openTutorialView.configure(viewModel: openTutorialViewModel)
        
//        openTutorialViewModel.hidesOpenTutorial.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Bool>) in
//            self?.setOpenTutorialHidden(animatableValue.value, animated: animatableValue.animated)
//        }
    }
    
    // TODO: - GT-1643: tutorial
    private func setOpenTutorialHidden(_ hidden: Bool, animated: Bool) {
//        openTutorialTop.constant = hidden ? (openTutorialView.frame.size.height * -1) : 0
//
//        if animated {
//            if !hidden {
//                openTutorialView.isHidden = false
//            }
//
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
//                self.view.layoutIfNeeded()
//                }, completion: { (finished: Bool) in
//                    if hidden {
//                        self.openTutorialView.isHidden = true
//                    }
//            })
//        }
//        else {
//            openTutorialView.isHidden = hidden
//            view.layoutIfNeeded()
//        }
    }
    
    func pageViewed() {
        contentView.viewModel.pageViewed()
    }
    
    func scrollToTop(animated: Bool) {
        // TODO: Implementing this method because this View implements ToolsMenuPageView protocol.  This method will need to go away when GT-1545 is implemented. (https://jira.cru.org/browse/GT-1545)  ~Levi
    }
}
