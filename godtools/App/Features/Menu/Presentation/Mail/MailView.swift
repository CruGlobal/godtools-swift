//
//  MailView.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI

class MailView: UIViewController {
        
    private let viewModel: MailViewModelType
    
    private lazy var mailComposeViewController = MFMailComposeViewController()
            
    required init(viewModel: MailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: MailView.self), bundle: nil)
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
        
        mailComposeViewController.setToRecipients(viewModel.toRecipients)
        mailComposeViewController.setSubject(viewModel.subject)
        mailComposeViewController.setMessageBody(viewModel.message, isHTML: viewModel.isHtml)
        mailComposeViewController.mailComposeDelegate = self
        
        addChild(mailComposeViewController)
        view.addSubview(mailComposeViewController.view)
        mailComposeViewController.didMove(toParent: self)
        
        mailComposeViewController.view.frame = view.bounds
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension MailView: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        viewModel.finishedSendingMail(result: result, error: error)
    }
}
