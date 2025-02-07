//
//  MobileContentRendererView.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

class MobileContentRendererView: MobileContentPagesView {
    
    private let viewModel: MobileContentRendererViewModel
    
    init(viewModel: MobileContentRendererViewModel, navigationBar: AppNavigationBar?) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, navigationBar: navigationBar, pageViewDelegate: nil, initialPageIndex: nil)
    }
    
    override init(viewModel: MobileContentPagesViewModel, navigationBar: AppNavigationBar?, pageViewDelegate: MobileContentPageViewDelegate?, initialPageIndex: Int?, loggingEnabled: Bool) {
        fatalError("not implemented")
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
    
    override func setupBinding() {
        super.setupBinding()
        
        viewModel.rendererWillChangeSignal.addObserver(self) { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.clearInitialPagePositions()
            weakSelf.resetInitialPagePositionsToAllVisiblePagePositions()
        }
    }
}
