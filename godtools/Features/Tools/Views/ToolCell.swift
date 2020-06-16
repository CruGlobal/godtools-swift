//
//  ToolCell.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolCellDelegate: class {
    func toolCellAboutToolTapped(toolCell: ToolCell)
    func toolCellOpenToolTapped(toolCell: ToolCell)
    func toolCellFavoriteTapped(toolCell: ToolCell)
}

class ToolCell: UITableViewCell {
    
    static let nibName: String = "ToolCell"
    static let reuseIdentifier: String = "ToolCellReuseIdentifier"
    
    private let toolCornerRadius: CGFloat = 12
    
    private var viewModel: ToolCellViewModelType?
    
    private weak var delegate: ToolCellDelegate?
    
    @IBOutlet weak private var toolShadowView: UIView!
    @IBOutlet weak private var toolContentView: UIView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    @IBOutlet weak private var translationsDownloadProgress: UIView!
    @IBOutlet weak private var attachmentsDownloadProgress: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var parallelLanguageLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var aboutToolButton: UIButton!
    @IBOutlet weak private var openToolButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    @IBOutlet weak private var translationsDownloadProgressWidth: NSLayoutConstraint!
    @IBOutlet weak private var attachmentsDownloadProgressWidth: NSLayoutConstraint!
    
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
        setTranslationProgress(progress: 0, animated: false)
        setAttachmentProgress(progress: 0, animated: false)
    }
    
    private func setupLayout() {
        
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
            self?.bannerImageView.image = bannerImage
            if bannerImage != nil {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self?.bannerImageView.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.attachmentDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setAttachmentProgress(progress: progress, animated: true)
        }
        
        viewModel.translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setTranslationProgress(progress: progress, animated: true)
        }
        
        viewModel.parallelLanguageName.addObserver(self) { [weak self] (name: String) in
            self?.parallelLanguageLabel.text = name
        }
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.resourceDescription
        
        let favoritedImage: UIImage?
        if viewModel.isFavorited {
            favoritedImage = ImageCatalog.favorited.image
        }
        else {
            favoritedImage = ImageCatalog.notFavorited.image
        }
        favoriteButton.setImage(favoritedImage, for: .normal)
    }
    
    private func setAttachmentProgress(progress: Double, animated: Bool) {
        
        setProgress(
            progressView: attachmentsDownloadProgress,
            progressWidth: attachmentsDownloadProgressWidth,
            progress: progress,
            animated: true
        )
    }
    
    private func setTranslationProgress(progress: Double, animated: Bool) {
        
        setProgress(
            progressView: translationsDownloadProgress,
            progressWidth: translationsDownloadProgressWidth,
            progress: progress,
            animated: true
        )
    }
    
    private func setProgress(progressView: UIView, progressWidth: NSLayoutConstraint, progress: Double, animated: Bool) {
        
        if progress == 0 {
            progressWidth.constant = 0
            progressView.alpha = 0
            toolContentView.layoutIfNeeded()
            return
        }
        
        progressWidth.constant = CGFloat(Double(toolContentView.frame.size.width) * progress)
        progressView.alpha = 1
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.toolContentView.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            toolContentView.layoutIfNeeded()
        }
        
        if progress == 1 {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                progressView.alpha = 0
            }, completion: nil)
        }
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
