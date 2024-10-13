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

    private var viewState: TodayNotesViewState?
    private var currentType: TypeTask = .all
    
    private lazy var headerView = makeHeaderView()
    private lazy var tabsView = makeTabsView()
    private lazy var tableView = makeTableView()
    private lazy var errorView = makeErrorView()
    
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
        tabsView.configureTabs(for: viewState.tabs)
        updateInterface(with: viewState)
    }
    
    func updateInterface(with viewState: TodayNotesViewState) {
        self.viewState = viewState
        
        headerView.title.text = viewState.headerTitle
        headerView.subtitle.text = viewState.headerSubtitle
        headerView.button.setTitle(viewState.headerButtonTitle, for: .normal)
        currentType = viewState.currentType
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        tableView.reloadData()
        
        tabsView.updateTabs(for: viewState.tabs.firstIndex { $0.type == currentType } ?? 0, tabs: viewState.tabs)
 }
    
    func changeTabInput(for index: Int) {
        guard let viewState else { return }
        presenter.changeTab(for: index, viewState: viewState)
    }
    
    func changeTabOutput(for index: Int, viewState: TodayNotesViewState) {
        self.viewState = viewState
        tabsView.selectedTab(for: index)
        tableView.reloadData()
    }
    
    func showError() {
        errorView.isHidden = false
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
        
        //Убираем выделение при тапе на ячейку
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
        headerView.button.addTarget(self, action: #selector(tapNewTask), for: .touchUpInside)
        
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addSubview(tabsView)
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            tabsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            tabsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tabsView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tabsView.bottomAnchor, constant: 40),
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

    private func makeHeaderView() -> TodayNotesHeaderView {
        let view = TodayNotesHeaderView().autoLayout()
        view.configure()
        return view
    }
    
    private func makeTabsView() -> TodayNotesTabsView {
        let view = TodayNotesTabsView().autoLayout()
        view.configure(self)
        return view
    }
    
    private func makeTableView() -> TodayNotesTableView {
        let tableView = TodayNotesTableView().autoLayout()
        tableView.configure()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }
    
    @objc private func tapNewTask() {
        showAlertTask { [weak presenter] title, subtitle in
            presenter?.createNewTask(title: title, subtitle: subtitle)
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
        let view = TodayNotesErrorView().autoLayout()
        view.configure(controller: self)
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
