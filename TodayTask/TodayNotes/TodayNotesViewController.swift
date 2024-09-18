//
//  TodayViewController.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//

import Foundation
import UIKit

final class TodayNotesViewController: UIViewController {
    
    private let presenter: TodayNotesPresenting

    private var tabsStack: [UIStackView] = []
    private var tabsCountLabel: [UILabel] = []
    
    private lazy var headerStack = makeHeaderStack()
    private lazy var headerTitle = makeHeaderTitle()
    private lazy var headerSubtitle = makeHeaderSubtitle()
    private lazy var headerButton = makeHeaderButton()
    private lazy var tabStack = makeTabStackView()
    private lazy var tableView = makeTableView()
    private lazy var errorView = makeErrorView()
    
    private var viewState: TodayNotesViewState?
    private var currentType: TypeTask = .all
    
    init(presenter: TodayNotesPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setup() {
        presenter.viewDidLoad()
    }
}

// MARK: - TodayNotesDisplayLogic
extension TodayNotesViewController: TodayNotesDisplayLogic {
    
    func configure(with viewState: TodayNotesViewState) {
        errorView.isHidden = true
        configureTabs(for: viewState.tabs)
        updateInterface(with: viewState)
        UserDefaults.standard.setValue(true, forKey: "networkDataLoaded")
    }
    
    func updateInterface(with viewState: TodayNotesViewState) {
        self.viewState = viewState
        
        headerTitle.text = viewState.headerTitle
        headerSubtitle.text = viewState.headerSubtitle
        headerButton.setTitle(viewState.headerButtonTitle, for: .normal)
        currentType = viewState.currentType
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        tableView.reloadData()
        
        reloadTabsCount()
        changeTab(for: viewState.tabs.firstIndex { $0.type == currentType } ?? 0, viewState: viewState)
    }
    
    func changeTab(for index: Int, viewState: TodayNotesViewState) {
        self.viewState = viewState
        
        setDefaultSettingsTab()
        
        guard let firstLabel = tabsStack[index].subviews.first as? UILabel else { return }
        let secondLabel = tabsCountLabel[index]
        
        firstLabel.font = UIFont.boldSystemFont(ofSize: 19)
        firstLabel.textColor = .systemBlue
        secondLabel.backgroundColor = .systemBlue
        
        tableView.reloadData()
    }
    
    func showError() {
        errorView.isHidden = false
    }
    
    @objc func didTapTab(_ sender: UITapGestureRecognizer) {
        guard 
            let index = sender.view?.tag,
            let viewState = self.viewState
        else {
            assertionFailure("Всегда должен быть индекс и стэйт по тапу на табы")
            return
        }
        presenter.changeTab(for: index, viewState: viewState)
        
    }
    
    @objc func tapNewTask() {
        showAlertTask { [weak self] title, subtitle in
            self?.presenter.createNewTask(title: title, subtitle: subtitle)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension TodayNotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewState?.items.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let model = viewState?.items[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? TodayNotesCell
        else {
            assertionFailure("Всегда должен быть айтем на индексе")
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.configure(with: model)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodayNotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        makeActionConfiguration(indexPath: indexPath)
    }
}

// MARK: - Private methods
extension TodayNotesViewController {
    private func setupUI() {
        view.backgroundColor = .systemGray6
        view.addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20)
        ])
        
        view.addSubview(headerButton)
        NSLayoutConstraint.activate([
            headerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            headerButton.bottomAnchor.constraint(equalTo: headerStack.bottomAnchor)
        ])
        
        view.addSubview(tabStack)
        NSLayoutConstraint.activate([
            tabStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 40),
            tabStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tabStack.bottomAnchor, constant: 40),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leftAnchor.constraint(equalTo: view.leftAnchor),
            errorView.rightAnchor.constraint(equalTo: view.rightAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func reloadTabsCount() {
        
        guard let viewState = self.viewState else { return }
        
        for (index, element) in viewState.tabs.enumerated() {
            tabsCountLabel[index].text = String(element.count)
        }
    }
    
    private func configureTabs(for tabs: [Tab]) {
        
        for (index, tab) in tabs.enumerated() {
            let stack = makeSubTabStackView(tab: tab)
            stack.tag = index
            tabStack.addArrangedSubview(stack)
            stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTab)))
            
            if index == .zero {
                let seporator = makeSeparatorTabView() // polosa
                tabStack.addArrangedSubview(seporator)
                
                NSLayoutConstraint.activate([
                    seporator.widthAnchor.constraint(equalToConstant: 2),
                    seporator.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
            tabsStack.append(stack)
        }
    }
    
    private func makeTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain).autoLayout()
        tableView.separatorStyle = .none
        
        
        tableView.register(TodayNotesCell.self, forCellReuseIdentifier: "NoteCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        return tableView
    }
    
    private func makeHeaderStack() -> UIStackView {
        let stack = UIStackView().autoLayout()
        stack.axis = .vertical
        stack.spacing = 3
        [headerTitle, headerSubtitle].forEach(stack.addArrangedSubview(_:))
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
        
        button.addTarget(self, action: #selector(tapNewTask), for: .touchUpInside)
        
        return button
    }
    
    private func makeTabStackView() -> UIStackView {
        
        let stack = UIStackView().autoLayout()
        stack.spacing = 20
        stack.axis = .horizontal
        
        return stack
    }
    
    private func makeSubTabStackView(tab: Tab) -> UIStackView {
        
        let labelTitle = UILabel()
        labelTitle.text = tab.title
        
        let labelCount = UILabel().autoLayout()
//        labelCount.text = String(tab.count)
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
    
    private func makeActionConfiguration(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] (_, _, _) in
            guard let task = self?.viewState?.items[indexPath.row] else { return }
            
            self?.showAlertTask(titleTask: task.description, title: task.title, subtitle: task.subtitle) { title, subtitle in
                self?.presenter.editTask(for: task.id, title: title, subtitle: subtitle)
            }
        }
        
        let deletedAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] (_, _, _)  in
            guard let id = self?.viewState?.items[indexPath.row].id else { return }
            self?.presenter.deleteTask(for: id)
        }
        
        return UISwipeActionsConfiguration(actions: [deletedAction, editAction])
    }
    
    private func showAlertTask(
        titleTask: String = "New Task",
        title: String? = nil,
        subtitle: String? = nil,
        completion: @escaping (_ title: String, _ subtitle: String) -> Void
    ) {
        
        let alert = UIAlertController(title: titleTask, message: "", preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Title"
            if let title = title {
                $0.text  = title
            }
        }
        
        alert.addTextField {
            $0.placeholder = "Todo"
            if let subtitle = subtitle {
                $0.text  = subtitle
            }
        }
        
        let actionSave = UIAlertAction(title: "Add", style: .default) { action in
            guard let title = alert.textFields?.first?.text,
                  let subtitle = alert.textFields?.last?.text
            else { return }
            completion(title, subtitle)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
    
    private func makeErrorView() -> UIView {
        let view = TodayNotesViewNetworkError().autoLayout()
        view.configure(presenter: presenter)
        view.isHidden = true
        
        return view
    }
}

extension UIView {
    func autoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
