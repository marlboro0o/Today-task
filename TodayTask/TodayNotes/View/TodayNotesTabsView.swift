//
//  TodayNotesTabsView.swift
//  TodayTask
//
//  Created by Андрей on 06.10.2024.
//

import Foundation
import UIKit

class TodayNotesTabsView: UIView {
   
    var controller: TodayNotesViewController?
    private var tabsStack: [UIStackView] = []
    private var tabsCountLabel: [UILabel] = []
    private lazy var tabStack = makeTabStackView()
    
    func configure(_ controller: TodayNotesViewController) {
        self.controller = controller
        
        addSubview(tabStack)
        NSLayoutConstraint.activate([
            tabStack.topAnchor.constraint(equalTo: topAnchor),
            tabStack.leftAnchor.constraint(equalTo: leftAnchor)
        ])
    }
    
    func configureTabs(for tabs: [Tab]) {
        for (index, tab) in tabs.enumerated() {
            let stack = makeSubTabStackView(tab: tab)
            stack.tag = index
            tabStack.addArrangedSubview(stack)
            stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTab)))
            
            if index == .zero {
                let seporator = makeSeparatorTabView()
                tabStack.addArrangedSubview(seporator)
                
                NSLayoutConstraint.activate([
                    seporator.widthAnchor.constraint(equalToConstant: 2),
                    seporator.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
            tabsStack.append(stack)
        }
    }
    
    func updateTabs(for index: Int, tabs: [Tab]) {
        setupTabsCount(tabs: tabs)
        selectedTab(for: index)
    }
    
    func selectedTab(for index: Int) {
        for (indexTab, element) in tabsStack.enumerated() {
            guard
                let titleView = element.subviews.first as? UILabel
            else {
                return
            }
            
            let isSelectedTab = indexTab == index
            
            titleView.font = isSelectedTab ? UIFont.boldSystemFont(ofSize: 19) : UIFont.systemFont(ofSize: 19)
            titleView.textColor = isSelectedTab ? .systemBlue : .gray
            
            let countView = tabsCountLabel[indexTab]
            countView.backgroundColor = isSelectedTab ? .systemBlue : .systemGray4
        }
    }
}

//MARK: - Private methods
extension TodayNotesTabsView {
    private func makeTabStackView() -> UIStackView {
        let stack = UIStackView().autoLayout()
        stack.spacing = 20
        stack.axis = .horizontal
        
        return stack
    }
    
    private func setupTabsCount(tabs: [Tab]) {
        for (index, element) in tabs.enumerated() {
            tabsCountLabel[index].text = String(element.count)
        }
    }
    
    @objc private func didTapTab(_ sender: UITapGestureRecognizer) {
        guard
            let index = sender.view?.tag
        else {
            assertionFailure("Всегда должен быть индекс и стэйт по тапу на табы")
            return
        }
        controller?.changeTabInput(for: index)
    }
    
    private func makeSubTabStackView(tab: Tab) -> UIStackView {
        
        let labelTitle = UILabel()
        labelTitle.text = tab.title
        
        let labelCount = UILabel().autoLayout()
        labelCount.textColor = .white
        labelCount.textAlignment = .center
        labelCount.font = UIFont.systemFont(ofSize: 12)
        labelCount.layer.cornerRadius = 10
        labelCount.layer.masksToBounds = true
       
        tabsCountLabel.append(labelCount)
        
        let stack = UIStackView(arrangedSubviews: [labelTitle, labelCount]).autoLayout()
        stack.spacing = 5
        stack.axis = .horizontal
        
        NSLayoutConstraint.activate([
            labelTitle.heightAnchor.constraint(equalToConstant: 20),
            labelCount.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        return stack
    }
    
    private func makeSeparatorTabView() -> UIView {
        let view = UIView().autoLayout()
        view.backgroundColor = .systemGray4
        return view
    }
    
    private func setDefaultSettingsTab() {
        
        for (index, element) in tabsStack.enumerated() {
            guard
                let titleView = element.subviews.first as? UILabel
            else {
                return
            }
            
            titleView.font = UIFont.systemFont(ofSize: 19)
            titleView.textColor = .gray
            
            let countView = tabsCountLabel[index]
            countView.backgroundColor = .systemGray4
            
        }
    }
}
