//
//  ToolCell.swift
//  godtools
//
//  Created by Levi Eggert on 7/09/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolCellDelegate: AnyObject {
    func toolCellAboutToolTapped(toolCell: ToolCell)
    func toolCellOpenToolTapped(toolCell: ToolCell)
    func toolCellFavoriteTapped(toolCell: ToolCell)
}

class ToolCell: UITableViewCell {
    
    static let nibName: String = "ToolCell"
    static let reuseIdentifier: String = "ToolCellReuseIdentifier"
    
    private let toolCornerRadius: CGFloat = 12
    
    private var viewModel: ToolCellViewModelType?
    private var isAnimatingBannerImage: Bool = false
    
    private weak var delegate: ToolCellDelegate?
    
    @IBOutlet weak private var toolShadowView: UIView!
    @IBOutlet weak private var toolContentView: UIView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    @IBOutlet weak private var attachmentsDownloadProgressView: UIView!
    @IBOutlet weak private var articlesDownloadProgressView: UIView!
    @IBOutlet weak private var translationsDownloadProgressView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var categoryLabel: UILabel!
    @IBOutlet weak private var parallelLanguageLabel: UILabel!
    @IBOutlet weak private var aboutToolButton: UIButton!
    @IBOutlet weak private var openToolButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    @IBOutlet weak private var attachmentsDownloadProgressWidth: NSLayoutConstraint!
    @IBOutlet weak private var articlesDownloadProgressWidth: NSLayoutConstraint!
    @IBOutlet weak private var translationsDownloadProgressWidth: NSLayoutConstraint!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        
        aboutToolButton.addTarget(self, action: #selector(handleAboutTool(button:)), for: .touchUpInside)
        openToolButton.addTarget(self, action: #selector(handleOpenTool(button:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(handleFavoriteTapped(button:)), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        delegate = nil
        setAttachmentsProgress(progress: 0, animated: false)
        setArticlesProgress(progress: 0, animated: false)
        setTranslationProgress(progress: 0, animated: false)
    }
    
    private func setupLayout() {
        
        setAttachmentsProgress(progress: 0, animated: false)
        setArticlesProgress(progress: 0, animated: false)
        setTranslationProgress(progress: 0, animated: false)
        
        // toolShadowView
        toolShadowView.layer.cornerRadius = toolCornerRadius
        toolShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        toolShadowView.layer.shadowColor = UIColor.black.cgColor
        toolShadowView.layer.shadowRadius = 3
        toolShadowView.layer.shadowOpacity = 0.3
        toolShadowView.clipsToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        // toolContentView
        toolContentView.layer.cornerRadius = toolCornerRadius
        toolContentView.clipsToBounds = true
        
        // bannerImageView
        bannerImageView.alpha = 0
        bannerImageView.contentMode = .scaleAspectFill
        
        // about and open buttons
        let buttonCornerRadius: CGFloat = 6
        aboutToolButton.layer.cornerRadius = buttonCornerRadius
        aboutToolButton.layer.borderWidth = 1
        aboutToolButton.layer.borderColor = aboutToolButton.titleColor(for: .normal)?.cgColor
        openToolButton.layer.cornerRadius = buttonCornerRadius
    }
    
    func configure(viewModel: ToolCellViewModelType, delegate: ToolCellDelegate) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        
        viewModel.bannerImage.addObserver(self) { [weak self] (bannerImage: UIImage?) in
            self?.setBannerImage(image: bannerImage)
        }
        
        viewModel.attachmentsDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setAttachmentsProgress(progress: progress, animated: true)
        }
        
        viewModel.translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setTranslationProgress(progress: progress, animated: true)
        }
        
        viewModel.parallelLanguageName.addObserver(self) { [weak self] (name: String) in
            self?.parallelLanguageLabel.text = name
        }
        
        viewModel.title.addObserver(self) { [weak self] (title: String) in
            self?.titleLabel.text = title
        }
        
        viewModel.category.addObserver(self) { [weak self] (category: String) in
            self?.categoryLabel.text = category
        }
        
        viewModel.isFavorited.addObserver(self) { [weak self] (isFavorited: Bool) in
            let favoritedImage: UIImage?
            if isFavorited {
                favoritedImage = ImageCatalog.favorited.image
            }
            else {
                favoritedImage = ImageCatalog.notFavorited.image
            }
            self?.favoriteButton.setImage(favoritedImage, for: .normal)
        }
        
        viewModel.aboutTitle.addObserver(self) { [weak self] (aboutTitle: String) in
            self?.aboutToolButton.setTitle(aboutTitle, for: .normal)
        }
        
        viewModel.openTitle.addObserver(self) { [weak self] (openTitle: String) in
            self?.openToolButton.setTitle(openTitle, for: .normal)
        }
        
        viewModel.toolSemanticContentAttribute.addObserver(self) { [weak self] (value: UISemanticContentAttribute) in
            self?.toolContentView.semanticContentAttribute = value
            self?.titleLabel.semanticContentAttribute = value
            self?.categoryLabel.semanticContentAttribute = value
        }
    }
    
    private func setBannerImage(image: UIImage?) {
        
        bannerImageView.image = image
        
        if !isAnimatingBannerImage {
            isAnimatingBannerImage = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.bannerImageView.alpha = 1
            }, completion: { [weak self] (finished: Bool) in
                self?.isAnimatingBannerImage = false
            })
        }
    }
    
    private func setAttachmentsProgress(progress: Double, animated: Bool) {
        
        UIView.setProgress(
            progress: progress,
            progressView: attachmentsDownloadProgressView,
            progressViewWidth: attachmentsDownloadProgressWidth,
            maxProgressViewWidth: toolContentView.frame.size.width,
            layoutView: toolContentView,
            animated: animated
        )
    }
    
    private func setArticlesProgress(progress: Double, animated: Bool) {
        
        UIView.setProgress(
            progress: progress,
            progressView: articlesDownloadProgressView,
            progressViewWidth: articlesDownloadProgressWidth,
            maxProgressViewWidth: toolContentView.frame.size.width,
            layoutView: toolContentView,
            animated: animated
        )
    }
    
    private func setTranslationProgress(progress: Double, animated: Bool) {
        
        UIView.setProgress(
            progress: progress,
            progressView: translationsDownloadProgressView,
            progressViewWidth: translationsDownloadProgressWidth,
            maxProgressViewWidth: toolContentView.frame.size.width,
            layoutView: toolContentView,
            animated: animated
        )
    }
    
    @objc func handleAboutTool(button: UIButton) {
        delegate?.toolCellAboutToolTapped(toolCell: self)
    }
    
    @objc func handleOpenTool(button: UIButton) {
        delegate?.toolCellOpenToolTapped(toolCell: self)
    }
    
    @objc func handleFavoriteTapped(button: UIButton) {
        delegate?.toolCellFavoriteTapped(toolCell: self)
    }
}
