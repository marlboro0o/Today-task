//
//  TodayNotesHeaderView.swift
//  TodayTask
//
//  Created by Андрей on 06.10.2024.
//

import Foundation
import UIKit

class TodayNotesHeaderView: UIView {
   
    var controller: TodayNotesViewController?
    lazy var headerStack = makeHeaderStack()
    lazy var title = makeHeaderTitle()
    lazy var subtitle = makeHeaderSubtitle()
    lazy var button = makeHeaderButton()
    
    func configure() {
        backgroundColor = .systemGray6
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
}

// MARK: - Private methods
extension TodayNotesHeaderView {
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

}
