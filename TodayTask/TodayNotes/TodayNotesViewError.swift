//
//  TodayNotesViewNetworkError.swift
//  TodayTask
//
//  Created by Андрей on 16.09.2024.
//

import Foundation
import UIKit

class TodayNotesViewError: UIView {
    
    var controller: TodayNotesViewController?
    
    func configure(controller: TodayNotesViewController) {
        
        self.controller = controller
        
        let viewError = UIView().autoLayout()
        viewError.backgroundColor = UIColor.white
        addSubview(viewError)
        
        let label = UILabel().autoLayout()
        label.text = "Network error"
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textAlignment = .center
        
        let button = UIButton(configuration: .plain()).autoLayout()
        button.setTitle("try again", for: .normal)
        button.addTarget(self, action: #selector(tapTryAgain), for: .touchUpInside)
        
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
    
    @objc func tapTryAgain() {
        controller?.setup()
    }
}
