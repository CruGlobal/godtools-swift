//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//


import TTTAttributedLabel
import UIKit

protocol ToolDetailViewControllerDelegate: class {
    func openToolTapped(toolDetail: ToolDetailViewController, resource: DownloadedResource)
}

class ToolDetailViewController: BaseViewController {
    
    enum SegmentedControlId: String {
        case about = "about"
        case language = "language"
    }
        
    private var detailsSegments: [GTSegment] = Array()
    private var aboutDescription: String = ""
    private var languageDescription: String = ""
    private var languageTextAlignment: NSTextAlignment = .left
    private var maxToolDetailTextHeight: CGFloat = 0
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak private var openToolButton: GTButton!
    @IBOutlet weak var mainButton: GTButton!
    @IBOutlet weak private var detailsControl: GTSegmentedControl!
    @IBOutlet weak private var detailsCollectionView: UICollectionView!
    @IBOutlet weak private var detailsTextView: UITextView!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var detailsShadow: UIView!
    @IBOutlet weak var downloadProgressView: GTProgressView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTopToTotalViewsLabel: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTopToOpenToolButton: NSLayoutConstraint!
    @IBOutlet weak private var detailsCollectionHeight: NSLayoutConstraint!
    
    
    let toolsManager = ToolsManager.shared
    
    var resource: DownloadedResource?
    
    weak var delegate: ToolDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openToolButton.designAsOpenToolButton()
            
        detailsCollectionView.register(
            UINib(nibName: ToolDetailCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: ToolDetailCell.reuseIdentifier
        )
        detailsTextView.isHidden = true
        
        detailsShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsShadow.layer.shadowColor = UIColor.black.cgColor
        detailsShadow.layer.shadowRadius = 5
        detailsShadow.layer.shadowOpacity = 0.3
        
        self.displayData()
        self.hideScreenTitle()
        registerForDownloadProgressNotifications()
        setTopHeight()
        
        openToolButton.addTarget(self, action: #selector(handleOpenTool(button:)), for: .touchUpInside)
        detailsCollectionView.delegate = self
        detailsCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            didLayoutSubviews = true
            if !showsOpenToolButton {
                mainButtonTopToTotalViewsLabel.isActive = true
                mainButtonTopToOpenToolButton.isActive = false
                openToolButton.isHidden = true
            }
                        
            let detailDescriptions: [String] = [aboutDescription, languageDescription]
            for description in detailDescriptions {
                detailsTextView.text = description
                let width: CGFloat = detailsCollectionView.bounds.size.width
                let detailsTextSize: CGSize = detailsTextView.sizeThatFits(CGSize(width: width, height: 0))
                if detailsTextSize.height > maxToolDetailTextHeight {
                    maxToolDetailTextHeight = detailsTextSize.height + 44
                }
                
                print(" detailsTextSize.height: \(detailsTextSize.height)")
                
                detailsLabel.numberOfLines = 0
                detailsLabel.text = description
                detailsLabel.layoutIfNeeded()
                let height: CGFloat = (description as NSString).size(withAttributes: [NSAttributedString.Key.font: detailsLabel.font]).height
                print(" detailsLabel.height: \(height)")
            }
            detailsCollectionHeight.constant = maxToolDetailTextHeight
            view.layoutIfNeeded()
            detailsCollectionView.reloadData()
        }
    }
    
    func setTopHeight() {
        let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let topBar = barHeight + statusBarHeight
        self.topLayoutConstraint.constant = topBar
        self.view.layoutIfNeeded()
    }

    // MARK: Present data
    
    fileprivate func displayData() {
        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
        guard let resource = resource else { return }
        
        // if tool is available in primary language, attempt to retrieve string based on that lanague else default to device language
        let localizedTotalViews = resource.isAvailableInLanguage(primaryLanguage) ? "total_views".localized(for: primaryLanguage?.code) ?? "total_views".localized : "total_views".localized
        self.totalViewsLabel.text = String.localizedStringWithFormat(localizedTotalViews, resource.totalViews)
        
        let localizedTotalLanguages =  resource.isAvailableInLanguage(primaryLanguage) ? "total_languages".localized(for: primaryLanguage?.code) ?? "total_languages".localized : "total_languages".localized
        
        self.titleLabel.text = resource.localizedName(language: primaryLanguage)
                
        let resourceTranslations = Array(Set(resource.translations))
        var translationStrings = [String]()
        
        let languageCode = primaryLanguage?.code ?? "en"
        let locale = resource.isAvailableInLanguage(primaryLanguage) ? Locale(identifier:  languageCode) : Locale.current
        for translation in resourceTranslations {
            guard translation.language != nil else {
                continue
            }
            guard let languageLocalName = translation.language?.localizedName(locale: locale) else {
                continue
            }
            translationStrings.append(languageLocalName)
        }
        
        self.displayButton()
        self.bannerImageView.image = BannerManager().loadFor(remoteId: resource.aboutBannerRemoteId)
        
        let textAlignment: NSTextAlignment = (resource.isAvailableInLanguage(primaryLanguage) && primaryLanguage?.isRightToLeft() ?? false) ? .right : .natural
        
        languageTextAlignment = textAlignment
        
        titleLabel.textAlignment = textAlignment
        totalViewsLabel.textAlignment = textAlignment
        
        aboutDescription = loadDescription()
        languageDescription = translationStrings.sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        let aboutSegment = GTSegment(
            id: SegmentedControlId.about.rawValue,
            title: String.localizedStringWithFormat(resource.isAvailableInLanguage(primaryLanguage) ? "about".localized(for: primaryLanguage?.code) ?? "about".localized : "about".localized, resource.totalViews)
        )
        
        let languageSement = GTSegment(
            id: SegmentedControlId.language.rawValue,
            title: String.localizedStringWithFormat(localizedTotalLanguages.localized, resource.numberOfAvailableLanguages())
        )
        
        detailsSegments = [aboutSegment, languageSement]
        detailsControl.configure(segments: detailsSegments, delegate: self)
    }
    
    private var showsOpenToolButton: Bool {
        return resource?.shouldDownload ?? false
    }
    
    private func displayButton() {
        if resource!.numberOfAvailableLanguages() == 0 {
            mainButton.designAsUnavailableButton()
        } else if resource!.shouldDownload {
            mainButton.designAsDeleteButton()
        } else {
            mainButton.designAsDownloadButton()
        }
    }
    
    private func loadDescription() -> String {
        let languagesManager = LanguagesManager()
        
        guard let language = languagesManager.loadPrimaryLanguageFromDisk() else {
            return resource!.descr ?? ""
        }
        
        if let translation = resource!.getTranslationForLanguage(language) {
            return translation.localizedDescription ?? ""
        }
        
        return resource!.descr ?? ""
    }
    
    private func registerForDownloadProgressNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(progressViewListenerShouldUpdate),
                                               name: .downloadProgressViewUpdateNotification,
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
        
        OperationQueue.main.addOperation {
            self.downloadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
            
            if progress.fractionCompleted == 1.0 {
                self.returnToHome()
            }
        }
    }
    
    @objc func handleOpenTool(button: UIButton) {
        guard let resource = resource else {
            assertionFailure("Resource should not be nil.")
            return
        }
        delegate?.openToolTapped(toolDetail: self, resource: resource)
    }
    
    @IBAction func mainButtonWasPressed(_ sender: Any) {
        
        self.baseDelegate?.goHome()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            if self.resource!.shouldDownload {
                DownloadedResourceManager().delete(self.resource!)
                self.downloadProgressView.setProgress(0.0, animated: false)
                NotificationCenter.default.post(name: .reloadHomeListNotification, object: nil)
            } else {
                DownloadedResourceManager().download(self.resource!)
            }
        }
        self.displayButton()
    }
    
    private func returnToHome() {
        let time = DispatchTime.now() + 0.55
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.baseDelegate?.goHome()
        }
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Tool Info"
    }
    
    override func siteSection() -> String {
        return "tools"
    }
    
    override func siteSubSection() -> String {
        return "add tools"
    }
    
}


extension ToolDetailViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
}

// MARK: - GTSegmentedControlDelegate

extension ToolDetailViewController: GTSegmentedControlDelegate {
    
    func segmentedControl(segmentedControl: GTSegmentedControl, didSelect segment: GTSegment, at index: Int) {
        
        detailsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension ToolDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailsCollectionView {
            return detailsSegments.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == detailsCollectionView {
                        
            let cell: ToolDetailCell = detailsCollectionView.dequeueReusableCell(withReuseIdentifier: ToolDetailCell.reuseIdentifier, for: indexPath) as! ToolDetailCell
            let segment: GTSegment = detailsSegments[indexPath.item]
            
            if let segmentId = SegmentedControlId(rawValue: segment.id) {
                switch segmentId {
                case .about:
                    cell.configure(details: aboutDescription, textAlignment: languageTextAlignment)
                case .language:
                    cell.configure(details: languageDescription, textAlignment: languageTextAlignment)
                }
            }
                        
            cell.backgroundColor = .clear
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == detailsCollectionView {
            return CGSize(
                width: detailsCollectionView.bounds.size.width,
                height: maxToolDetailTextHeight
            )
        }
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == detailsCollectionView {
            return 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == detailsCollectionView {
            return 0
        }
        return 0
    }
}
