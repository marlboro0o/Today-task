//
//  TodayNotesHeaderView.swift
//  TodayTask
//
//  Created by Андрей on 06.10.2024.
//

import Foundation
import UIKit

final class TodayNotesHeaderView: UIView {
   
    private var actionNewTask: (() -> Void)?
    private lazy var headerStack = makeHeaderStack()
    private lazy var title = makeHeaderTitle()
    private lazy var subtitle = makeHeaderSubtitle()
    private lazy var button = makeHeaderButton()
    
    func configure(with viewState: TodayNotesViewState) {
        title.text = viewState.headerTitle
        subtitle.text = viewState.headerSubtitle
        button.setTitle(viewState.headerButtonTitle, for: .normal)
    }
}

// MARK: - Initialization
extension TodayNotesHeaderView {
    convenience init(actionNewTask: (() -> Void)?) {
        self.init()
        self.actionNewTask = actionNewTask
        setupUI()
    }
}

// MARK: - Private methods
extension TodayNotesHeaderView {
    
    private func setupUI() {
        backgroundColor = .systemGray6
        button.addTarget(self, action: #selector(tapNewTask), for: .touchUpInside)
        
        addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            headerStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        ])
        
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: headerStack.bottomAnchor)
        ])
    }
    
    private func makeHeaderStack() -> UIStackView {
        let stack = UIStackView().autoLayout()
        stack.axis = .vertical
        stack.spacing = 3
        [title, subtitle].forEach(stack.addArrangedSubview(_:))
        return stack
    }
    
    private func makeHeaderTitle() -> UILabel {
        let label = UILabel().autoLayout()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }
    
    private func makeHeaderSubtitle() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }
    
    private func makeHeaderButton() -> UIButton {
        let button = UIButton(configuration: .tinted()).autoLayout()
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        
        return button
    }

    @objc private func tapNewTask() {
        actionNewTask?()
    }
}
