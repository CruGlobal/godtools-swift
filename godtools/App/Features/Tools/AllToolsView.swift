//
//  AllToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class AllToolsView: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AllToolsContentViewModel
    private let contentView: UIHostingController<AllToolsContentView>
    
    // MARK: - Outlets
    
    @IBOutlet weak private var favoritingToolMessageView: FavoritingToolMessageView!
    @IBOutlet weak private var messageLabel: UILabel!
    
    @IBOutlet weak private var favoritingToolMessageViewTop: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    required init(viewModel: AllToolsContentViewModel) {
        self.viewModel = viewModel
        contentView = UIHostingController(rootView: AllToolsContentView(viewModel: viewModel))
        
        super.init(nibName: String(describing: AllToolsView.self), bundle: nil)
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
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        setupLayout()
        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.pageViewed()
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func setupBinding() {
        
        // TODO: - Fix favoriting message in followup ticket
        let favoritingToolMessageViewModel = viewModel.createFavoritingToolMessageViewModel()
        favoritingToolMessageView.configure(viewModel: favoritingToolMessageViewModel)
        
        favoritingToolMessageViewModel.hidesMessage.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Bool>) in
            self?.setFavoritingToolMessageHidden(animatableValue.value, animated: animatableValue.animated)
        }
        
        // TODO: - Fix message label in followup ticket
//        viewModel.message.addObserver(self, onObserve: { [weak self] (message: String) in
//            self?.messageLabel.isHidden = message.isEmpty
//            self?.messageLabel.text = message
//        })
    }
    
    // TODO: - Fix favoriting message in followup ticket
    private func setFavoritingToolMessageHidden(_ hidden: Bool, animated: Bool) {
                
        favoritingToolMessageViewTop.constant = hidden ? (favoritingToolMessageView.frame.size.height * -1) : 0
        
        if animated {
            if !hidden {
                favoritingToolMessageView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: {(finished: Bool) in
                    if hidden {
                        self.favoritingToolMessageView.isHidden = true
                    }
            })
        }
        else {
            favoritingToolMessageView.isHidden = hidden
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Public
    
    func scrollToTopOfToolsList(animated: Bool) {
        viewModel.scrollToTop(animated: animated)
    }
}
