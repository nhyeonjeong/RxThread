//
//  ShoppingListViewController.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ShoppingListViewController: UIViewController {
    let textFieldView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    let textField = {
        let view = UITextField()
        view.placeholder = "무엇을 구매하실 건가요?"
        return view
    }()
    
    let addbutton = {
        let view = UIButton()
        view.setTitle("  추가  ", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        return view
    }()
    
    let todoTableView = {
        let view = UITableView()
        view.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: ShoppingListTableViewCell.identifier)
        return view
    }()
    
    var data: [ShoppingListModel] = []
    lazy var items = BehaviorSubject(value: data)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
        setNavigationItem()
    }
    
    func bind() {
        items
            .bind(to: todoTableView.rx.items(cellIdentifier: ShoppingListTableViewCell.identifier, cellType: ShoppingListTableViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        
        todoTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let vc = EditTodoViewController()
                vc.todoText = owner.data[indexPath.row].todoText
                vc.editedTodo = { todo in
                        owner.data[indexPath.row].todoText = todo
                        owner.items.onNext(owner.data)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
 
}

extension ShoppingListViewController {
    func configureHierarchy() {
        textFieldView.addView([textField, addbutton])
        view.addView([textFieldView, todoTableView])
    }
    
    func configureConstraints() {
        textFieldView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(60)
            
        }
        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        }
        addbutton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.leading.greaterThanOrEqualTo(textField.snp.trailing)
//            make.verticalEdges.equalToSuperview().inset(4)
        }
        todoTableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            
        }
    }
    func configureView() {
        view.backgroundColor = .white
    }
    
    func setNavigationItem() {
        navigationItem.title = "쇼핑"
    }
}
