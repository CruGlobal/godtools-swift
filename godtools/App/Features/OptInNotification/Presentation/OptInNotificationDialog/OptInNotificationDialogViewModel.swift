//
//  NotificationPermissionDialog.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

//import Combine
//import Foundation
//import UIKit
//
//class OptInNotificationDialogViewModel: AlertMessageViewModelType {
//
//    private let viewOptInDialogDomainModel: ViewOptInDialogDomainModel
//
//    private weak var flowDelegate: FlowDelegate?
//    
//    let title: String?
//    let message: String?
//    let cancelTitle: String?
//    let acceptTitle: String
//
//    init(flowDelegate: FlowDelegate, viewOptInDialogDomainModel: ViewOptInDialogDomainModel) {
//       
//        self.flowDelegate = flowDelegate
//        self.viewOptInDialogDomainModel = viewOptInDialogDomainModel
//
//        title = viewOptInDialogDomainModel.interfaceStrings.title
//        message = viewOptInDialogDomainModel.interfaceStrings.body
//        cancelTitle = viewOptInDialogDomainModel.interfaceStrings.cancelActionTitle
//        acceptTitle = viewOptInDialogDomainModel.interfaceStrings.settingsActionTitle
//    }
//
//    deinit {
//        print("x deinit: \(type(of: self))")
//    }
//    
//    func cancelTapped() {
//        
//        flowDelegate?.navigate(step: .cancelTappedFromOptInNotificationDialog)
//    }
//
//    func acceptTapped() {
//        
//        flowDelegate?.navigate(step: .settingsTappedFromOptInNotificationDialog)
//    }
//}
