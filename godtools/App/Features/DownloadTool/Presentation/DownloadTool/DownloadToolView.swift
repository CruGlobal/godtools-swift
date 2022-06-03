//
//  DownloadToolView.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class DownloadToolView: UIViewController {
    
    private let viewModel: DownloadToolViewModelType
        
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var progressLabel: UILabel!
    
    required init(viewModel: DownloadToolViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: DownloadToolView.self), bundle: nil)
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
        
        setupLayout()
        setupBinding()
        
        _ = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.image,
            color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
            target: self,
            action: #selector(handleClose(barButtonItem:))
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.pageDidAppear()
    }
    
    private func setupLayout() {
        
        progressView.progress = 0
    }
    
    private func setupBinding() {
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
        
        viewModel.downloadProgress.addObserver(self) { [weak self] (progress: Double) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self?.progressView.progress = CGFloat(progress)
            }, completion: nil)
        }
        
        viewModel.progressValue.addObserver(self) { [weak self] (progressValue: String) in
            self?.progressLabel.text = progressValue
        }
        
        viewModel.message.addObserver(self) { [weak self] (message: String) in
            self?.messageLabel.text = message
        }
    }
    
    @objc private func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeTapped()
    }
    
    func completeDownloadProgress(didCompleteDownload: @escaping (() -> Void)) {
        viewModel.completeDownloadProgress(didCompleteDownload: didCompleteDownload)
    }
}
