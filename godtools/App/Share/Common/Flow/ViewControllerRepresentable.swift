//
//  ViewControllerRepresentable.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import SwiftUI
import UIKit

public struct ViewControllerRepresentable: UIViewControllerRepresentable {
    
    private let viewController: UIViewController
    
    public init(viewController: UIViewController) {
        
        self.viewController = viewController
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
