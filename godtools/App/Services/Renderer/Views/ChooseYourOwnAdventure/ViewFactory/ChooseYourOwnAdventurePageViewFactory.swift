//
//  ChooseYourOwnAdventurePageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ChooseYourOwnAdventurePageViewFactory: MobileContentPageViewFactoryType {
    
    private let deepLinkingService: DeepLinkingServiceType
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, deepLinkingService: DeepLinkingServiceType) {
        
        self.flowDelegate = flowDelegate
        self.deepLinkingService = deepLinkingService
    }
    
    func viewForRenderableModel(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        if let contentPage = renderableModel as? MultiplatformContentPage {
            
            guard let flowDelegate = self.flowDelegate else {
                return nil
            }
            
            let page: Int = rendererPageModel.page
            let contentInsets: UIEdgeInsets
            let itemSpacing: CGFloat
            
            if page == 0 {
                
                contentInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
                itemSpacing = 28
            }
            else if page == 1 {
                
                contentInsets = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
                itemSpacing = 30
            }
            else {
                
                contentInsets = .zero
                itemSpacing = 20
            }
            
            let viewModel = MobileContentContentPageViewModel(
                flowDelegate: flowDelegate,
                contentPage: contentPage,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkingService
            )
            
            let view = MobileContentContentPageView(
                viewModel: viewModel,
                contentInsets: contentInsets,
                itemSpacing: itemSpacing
            )
            
            return view
        }
        else if let contentFlow = renderableModel as? GodToolsToolParser.Flow {
            
            let viewModel = MobileContentFlowViewModel(
                contentFlow: contentFlow,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentFlowView(viewModel: viewModel, itemSpacing: 16)
            
            return view
        }
        
        return nil
    }
}
