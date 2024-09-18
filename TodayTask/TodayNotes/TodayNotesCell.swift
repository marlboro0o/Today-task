//
//  TodayNotesCustomCell.swift
//  TodayTask
//
//  Created by Андрей on 09.09.2024.
//

import UIKit

final class TodayNotesCell: UITableViewCell {
    private let titleStack = UIStackView().autoLayout()
    private let createdDateStack = UIStackView().autoLayout()
    private var viewState: TodayNotesCellViewState?
    private lazy var containerView = makeContainerView()
    private lazy var titleLabel = makeTitleLabel()
    private lazy var subTitleLabel = makeSubTitleLabel()
    private lazy var completedView = makeCompletedView()
    private lazy var completedImageView = makeCompletedImageView()
    private lazy var createdDateDayLabel = makeCreatedDateDayLabel()
    private lazy var createdDateTimeLabel = makeCreatedDateTimeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Display logic
    override func prepareForReuse() {
        titleLabel.text = nil
        subTitleLabel.text = nil
        completedView.backgroundColor = .clear
        completedImageView.image = nil
        createdDateDayLabel.text = nil
        createdDateTimeLabel.text = nil
    }
    
    func configure(with viewState: TodayNotesCellViewState) {
        
        self.viewState = viewState
        var attribute: [NSAttributedString.Key : Any] = [:]
        
        if viewState.isCompleted {
            // Установка зачеркнутого стиля
            attribute[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            // Установка картинки
            completedImageView.image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
            completedView.backgroundColor = .blue
        } else {
            attribute[.strikethroughStyle] = NSUnderlineStyle(rawValue: 0)
        }
        
        titleLabel.attributedText = NSAttributedString(string: viewState.title, attributes: attribute)
        
        subTitleLabel.text = viewState.subtitle
        createdDateDayLabel.text = viewState.createdDateDay
        createdDateTimeLabel.text = viewState.createdDateTime
        
    }
    
    @objc func completedTap() {
        viewState?.action?()
    }
}
    
    // MARK: - Private metods
extension TodayNotesCell {
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subTitleLabel)
        titleStack.axis = .vertical
        titleStack.spacing = 5
        
        containerView.addSubview(titleStack)
        containerView.addSubview(completedView)
        completedView.addSubview(completedImageView)
        
        let seporator = UIView().autoLayout()
        seporator.backgroundColor = .systemGray5
        containerView.addSubview(seporator)
        
        createdDateStack.addArrangedSubview(createdDateDayLabel)
        createdDateStack.addArrangedSubview(createdDateTimeLabel)
        containerView.addSubview(createdDateStack)
        createdDateStack.spacing = 10
        
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleStack.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20)
            ])
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.7)
            ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.7)
            ])
        
        NSLayoutConstraint.activate([
            completedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            completedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            completedView.widthAnchor.constraint(equalToConstant: 32),
            completedView.heightAnchor.constraint(equalToConstant: 32)
            ])
        
        NSLayoutConstraint.activate([
            completedImageView.topAnchor.constraint(equalTo: completedView.topAnchor, constant: 8),
            completedImageView.leadingAnchor.constraint(equalTo: completedView.leadingAnchor, constant: 8),
            completedImageView.trailingAnchor.constraint(equalTo: completedView.trailingAnchor, constant: -8),
            completedImageView.bottomAnchor.constraint(equalTo: completedView.bottomAnchor, constant: -8)
            ])
        
        NSLayoutConstraint.activate([
            seporator.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 10),
            seporator.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20),
            seporator.rightAnchor.constraint(equalTo: completedView.leftAnchor, constant: -10),
            seporator.heightAnchor.constraint(equalToConstant: 2)
            ])
        
        NSLayoutConstraint.activate([
            createdDateStack.topAnchor.constraint(equalTo: seporator.bottomAnchor, constant: 20),
            createdDateStack.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20)
        ])
        
    }
    
    private func makeContainerView() -> UIView {
        let view = UIView().autoLayout()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        return view
    }
    
    private func makeCompletedView() -> UIView {
        
        let completedView = UIView().autoLayout()
        
        completedView.clipsToBounds = true
        completedView.layer.cornerRadius = 16
        completedView.layer.borderColor = UIColor.gray.cgColor
        completedView.layer.borderWidth = 1
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(completedTap))
        completedView.addGestureRecognizer(gesture)
        
        return completedView
    }
    
    private func makeCompletedImageView() -> UIImageView {
        let image = UIImageView().autoLayout()
        image.tintColor = .white
        image.contentMode = .scaleAspectFit
        return image
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel().autoLayout()
        label.font = UIFont.systemFont(ofSize: 22)
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }
    
    private func makeSubTitleLabel() -> UILabel {
        let label = UILabel().autoLayout()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }
    
    private func makeCreatedDateDayLabel() -> UILabel {
        let label = UILabel().autoLayout()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        
        return label
    }
    
    private func makeCreatedDateTimeLabel() -> UILabel {
        let label = UILabel().autoLayout()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .systemGray4
        
        return label
    }
}
