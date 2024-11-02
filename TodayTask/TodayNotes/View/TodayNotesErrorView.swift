//
//  TodayNotesErrorView.swift
//  TodayTask
//
//  Created by Андрей on 16.09.2024.
//

import Foundation
import UIKit

final class TodayNotesErrorView: UIView {
    
    private var state: TodayNotesErrorViewState?
    private var action: (() -> Void)?
    private lazy var label = makeLabel()
    private lazy var button = makeButton()
    
    func configure(state: TodayNotesErrorViewState) {
        
        self.state = state
        label.text = state.title
        button.setTitle(state.titleButton, for: .normal)
    }
    
}

//MARK: - Initialization
extension TodayNotesErrorView {
    convenience init(state: TodayNotesErrorViewState?) {
        self.init()
        setupUI()
    }
}

//MARK: - Private methods
extension TodayNotesErrorView {
    private func setupUI() {
        let viewError = UIView().autoLayout()
        viewError.backgroundColor = UIColor.white
        addSubview(viewError)
        
        let stack = UIStackView(arrangedSubviews: [label, button]).autoLayout()
        stack.axis = .vertical
        stack.backgroundColor = .white
        
        viewError.addSubview(stack)
        
        NSLayoutConstraint.activate([
            viewError.topAnchor.constraint(equalTo: topAnchor),
            viewError.leftAnchor.constraint(equalTo: leftAnchor),
            viewError.rightAnchor.constraint(equalTo: rightAnchor),
            viewError.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.widthAnchor.constraint(equalToConstant: 150),
            stack.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func makeLabel() -> UILabel {
        let label = UILabel().autoLayout()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textAlignment = .center
        return label
    }
    
    private func makeButton() -> UIButton {
        let button = UIButton(configuration: .plain()).autoLayout()
        button.addTarget(self, action: #selector(tapTryAgain), for: .touchUpInside)
        return button
    }
    
    @objc 
    private func tapTryAgain() {
        state?.action()
    }
}
