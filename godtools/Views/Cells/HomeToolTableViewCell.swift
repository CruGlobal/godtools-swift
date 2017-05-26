//
//  HomeToolTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol HomeToolTableViewCellDelegate {
    func downloadButtonWasPressed(resource: DownloadedResource)
    func infoButtonWasPressed(resource: DownloadedResource)
}

@IBDesignable
class HomeToolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var contentTopView: UIView!
    @IBOutlet weak var contentBottomView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var greyVerticalLine: UIImageView!
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var numberOfViewsLabel: GTLabel!
    @IBOutlet weak var languageLabel: GTLabel!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfViewsLeadingConstraint: NSLayoutConstraint!
    @IBInspectable var leftConstraintValue: CGFloat = 8.0
    @IBOutlet weak var downloadProgressView: GTProgressView!
    
    private (set) var resource: DownloadedResource?
    private (set) var cellDelegate: HomeToolTableViewCellDelegate?
    private (set) var isAvailable = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        registerProgressViewListener()
    }
    
    func configure(resource: DownloadedResource,
                   primaryLanguage: Language?,
                   parallelLanguage: Language?,
                   banner: UIImage?,
                   delegate: HomeToolTableViewCellDelegate) {
        self.resource = resource
        self.cellDelegate = delegate
        
        let isAvailableInPrimaryLanguage = resource.isAvailableInLanguage(primaryLanguage)
        
        configureLabels(resource: resource,
                        isAvailableInPrimaryLanguage: isAvailableInPrimaryLanguage,
                        primaryLanguage: primaryLanguage,
                        parallelLanguage: parallelLanguage)
        
        downloadProgressView.setProgress(0.0, animated: false)
        
        selectionStyle = isAvailableInPrimaryLanguage ? .default : .none
        isAvailable = isAvailableInPrimaryLanguage
        
        if (resource.shouldDownload) {
            setCellAsDisplayOnly()
        }
        
        if banner != nil {
            bannerImageView.image = banner
        }
    }
    
    private func configureLabels(resource: DownloadedResource,
                                 isAvailableInPrimaryLanguage: Bool,
                                 primaryLanguage: Language?,
                                 parallelLanguage: Language?) {
        if isAvailableInPrimaryLanguage && primaryLanguage != nil {
            titleLabel.isEnabled = true
            titleLabel.text = resource.getTranslationForLanguage(primaryLanguage!)?.localizedName ?? resource.name
        } else {
            titleLabel.isEnabled = false
            titleLabel.text = resource.name
        }
        
        
        languageLabel.text = resource.isAvailableInLanguage(parallelLanguage) ? parallelLanguage!.localizedName() : nil
        
        numberOfViewsLabel.text = String.localizedStringWithFormat("total_views".localized, resource.totalViews)
    }
    
    private func setCellAsDisplayOnly() {
        downloadButton.isHidden = true
        greyVerticalLine.isHidden = true
        titleLeadingConstraint.constant = leftConstraintValue
        numberOfViewsLeadingConstraint.constant = leftConstraintValue
    }
    
    // MARK: - Actions
    
    @IBAction func pressDownloadButton(_ sender: Any) {
        cellDelegate?.downloadButtonWasPressed(resource: resource!)
    }
    
    @IBAction func pressInfoButton(_ sender: Any) {
        cellDelegate?.infoButtonWasPressed(resource: resource!)
    }
    
    // MARK: UI 
    
    func setupUI() {
        self.selectionStyle = .none
        self.backgroundColor = .gtWhite
        self.setBorders()
        self.setShadows()
        self.displayData()
    }
    
    func setBorders() {
        let layer = borderView.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func setShadows() {
        self.shadowView.backgroundColor = .gtWhite
        let layer = shadowView.layer
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        layer.shadowOpacity = 0.4
        layer.shouldRasterize = true
    }

    func setLanguage(_ language: String?) {
        self.languageLabel.text = language
    }
    
    // MARK: Present data
    
    fileprivate func displayData() {
        self.numberOfViewsLabel.text = String.localizedStringWithFormat("total_views".localized, "5,000,000")
    }
    
    // MARK: Progress view listener
    
    private func registerProgressViewListener() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(progressViewListenerShouldUpdate),
                                               name: .downloadProgressViewUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshBannerImage),
                                               name: .downloadBannerCompleteNotifciation,
                                               object: nil)
    }
    
    @objc private func progressViewListenerShouldUpdate(notification: NSNotification) {
        guard let resourceId = notification.userInfo![GTConstants.kDownloadProgressResourceIdKey] as? String else {
            return
        }
        
        if resourceId != resource!.remoteId {
            return
        }
        
        guard let progress = notification.userInfo![GTConstants.kDownloadProgressProgressKey] as? Progress else {
            return
        }

        let progressFraction = Float(progress.fractionCompleted >= 1.0 ? 0.0 : progress.fractionCompleted)
        let animated = progressFraction > 0.0
        
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(progressFraction, animated: animated)
        }
    }
    
    @objc private func refreshBannerImage(notification: NSNotification) {
        guard let resourceId = notification.userInfo![GTConstants.kDownloadBannerResourceIdKey] as? String else {
            return
        }
        
        if resourceId != resource!.remoteId {
            return
        }
        
        guard let bannerImage = BannerManager.shared.loadFor(resource!) else {
            return
        }
        
        DispatchQueue.main.async {
            UIView.transition(with: self.bannerImageView,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.bannerImageView.image = bannerImage },
                              completion: nil)
        }
    }
}
