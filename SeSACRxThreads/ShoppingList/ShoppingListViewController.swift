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
        view.rowHeight = 50
        view.separatorStyle = .none
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
                // 체크박스 누르면 해제...
                cell.checkboxButton.rx.tap
                    .bind(with: self) { owner, _ in
                        print("click checkbox")
                        owner.data[row].isChecked.toggle()
                        owner.data.remove(at: row)
                        owner.items.onNext(owner.data)
                    }
                    .disposed(by: cell.disposeBag)
                // 즐겨찾기 누르면 즐겨찾기
                cell.starButton.rx.tap
                    .bind(with: self) { owner, _ in
                        print("click starbutton")
                        owner.data[row].isFavorite.toggle()
                        owner.items.onNext(owner.data)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 추가버튼
        addbutton.rx.tap
            .bind(with: self) { owner, _ in
                print("addbutton")
                let newData = ShoppingListModel(isChecked: false, todoText: owner.textField.text!, isFavorite: false)
                owner.data.append(newData)
                owner.items.onNext(owner.data)
                // 검색글자 지우기
//                owner.textField.text = ""
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
        
        // 실시간 검색
        textField.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                let result = value.isEmpty ? owner.data : owner.data.filter{ $0.todoText.contains(value)}
                owner.items.onNext(result)
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
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureView() {
        view.backgroundColor = .white
    }
    
    func setNavigationItem() {
        navigationItem.title = "쇼핑"
    }
}
