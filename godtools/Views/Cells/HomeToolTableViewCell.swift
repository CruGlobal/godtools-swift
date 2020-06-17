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
    
    // Now using this for description of Tract
    @IBOutlet weak var tractDescriptionLabel: GTLabel!
    
    @IBOutlet weak var languageLabel: GTLabel!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfViewsLeadingConstraint: NSLayoutConstraint!
    @IBInspectable var leftConstraintValue: CGFloat = 8.0
    @IBInspectable var defaultTitleLeadingConstraint: CGFloat = 47.0
    @IBInspectable var defaultNumberOfViewsLeadingConstraint: CGFloat = 47.0
    @IBOutlet weak var downloadProgressView: GTProgressView!
    
    private (set) var resource: DownloadedResource?
    private (set) var cellDelegate: HomeToolTableViewCellDelegate?
    private (set) var isAvailable = true
    private var isHomeView = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        registerProgressViewListener()
    }
    
    override func prepareForReuse() {
        downloadButton.isHidden = false
        greyVerticalLine.isHidden = false
        titleLeadingConstraint.constant = defaultTitleLeadingConstraint
        numberOfViewsLeadingConstraint.constant = defaultNumberOfViewsLeadingConstraint
    }
    
    func configure(resource: DownloadedResource,
                   primaryLanguage: Language?,
                   parallelLanguage: Language?,
                   banner: UIImage?,
                   delegate: HomeToolTableViewCellDelegate,
                   isHomeView: Bool = false) {
        self.resource = resource
        self.cellDelegate = delegate
        self.isHomeView = isHomeView
        
        let isAvailableInPrimaryLanguage = resource.isDownloadedInLanguage(primaryLanguage)
        
        configureLabels(resource: resource,
                        isAvailableInPrimaryLanguage: isAvailableInPrimaryLanguage,
                        primaryLanguage: primaryLanguage,
                        parallelLanguage: parallelLanguage)
        
        downloadProgressView.setProgress(0.0, animated: false)
        downloadProgressView.accessibilityIdentifier = "Progress"
        
        isAvailable = isAvailableInPrimaryLanguage
        
        if resource.shouldDownload || resource.numberOfAvailableLanguages() == 0 {
            setCellAsDisplayOnly()
        }
        
        bannerImageView.image = banner ?? #imageLiteral(resourceName: "cell_banner_placeholder")

        accessibilityIdentifier = resource.name
    }
    
    private func configureLabels(resource: DownloadedResource,
                                 isAvailableInPrimaryLanguage: Bool,
                                 primaryLanguage: Language?,
                                 parallelLanguage: Language?) {

        titleLabel.text = resource.localizedName(language: primaryLanguage)
        
        configureParallelLanguageLabel(parallelLanguage: parallelLanguage)

        tractDescriptionLabel.text = loadDescription(resource: resource)
    }
    
    private func configureParallelLanguageLabel(parallelLanguage: Language?) {
        guard let resource = resource, let parallelLanguage = parallelLanguage else {
            languageLabel.text = nil
            return
        }
        if resource.isAvailableInLanguage(parallelLanguage)  {
            let check: String = "✓ "
            languageLabel.text = check + parallelLanguage.localizedName()
        } else {
            languageLabel.text = nil
        }
    }
    
    private func setCellAsDisplayOnly() {
        downloadButton.isHidden = true
        greyVerticalLine.isHidden = true
        titleLeadingConstraint.constant = leftConstraintValue
        numberOfViewsLeadingConstraint.constant = leftConstraintValue
    }
    
    private func loadDescription(resource: DownloadedResource) -> String {
        let languagesManager = LanguagesManager()
        
        guard let language = languagesManager.loadPrimaryLanguageFromDisk() else {
            return resource.descr ?? ""
        }

        guard let translation = resource.getTranslationForLanguage(language) else {
            return resource.descr ?? ""
        }
        guard let tagline = translation.tagline else {
            return translation.localizedDescription ?? ""
        }

        return tagline
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
        if let resource = self.resource {
           self.displayData(resource: resource)
        }
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
    
    fileprivate func displayData(resource: DownloadedResource) {
        self.tractDescriptionLabel.text = loadDescription(resource: resource)
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
        // progress view should only be updated if cell is displayed in 'My Tools' view
        guard isHomeView else { return }
        
        guard let resourceId = notification.userInfo![GTConstants.kDownloadProgressResourceIdKey] as? String else {
            return
        }
        
        if resourceId != resource!.remoteId {
            return
        }
        
        guard let progress = notification.userInfo![GTConstants.kDownloadProgressProgressKey] as? Progress else {
            return
        }
        
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
        }
    }
    
    @objc private func refreshBannerImage(notification: NSNotification) {
        
        guard let resourceId = notification.userInfo![GTConstants.kDownloadBannerResourceIdKey] as? String else {
            return
        }
        
        if resourceId != resource!.remoteId {
            return
        }
        
        guard let bannerImage = BannerManager().loadFor(remoteId: resourceId) else {
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
