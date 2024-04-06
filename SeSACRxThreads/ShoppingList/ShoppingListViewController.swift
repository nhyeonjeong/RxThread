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

final class ShoppingListViewController: UIViewController {
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
    let viewModel = ShoppingListViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
        setNavigationItem()
    }
    /*
     // input output pattern 도입 전
    func bind() {
        viewModel.items
//            .asDriver()
            .bind(to: todoTableView.rx.items(cellIdentifier: ShoppingListTableViewCell.identifier, cellType: ShoppingListTableViewCell.self)) {(row, element, cell) in
                
                cell.upgradeCell(element) // 위에서 drive를 쓰면 오류나느 이유?
                // 체크박스 누르면 해제...
                cell.checkboxButton.rx.tap
                    .map{ row }
                    .bind(to: self.viewModel.checkboxButtonTap) // 왜 .drive로 하면 안되는지,,?
                    .disposed(by: cell.disposeBag)
                // 즐겨찾기 누르면 즐겨찾기
                cell.starButton.rx.tap
                    .map{ row }
                    .bind(to: self.viewModel.favoriteButtonTap)
                    .disposed(by: cell.disposeBag)

            }
            .disposed(by: disposeBag)
        
        // 추가버튼
        addbutton.rx.tap
            .map{ self.textField.text! }
            .bind(to: viewModel.addButtonTap)
            .disposed(by: disposeBag)
        
        // 화면 전환 - VC에 있어야 될 듯
        todoTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let vc = EditTodoViewController()
                vc.todoText = owner.viewModel.data[indexPath.row].todoText
                vc.editedTodo = { todo in
                    owner.viewModel.data[indexPath.row].todoText = todo
                    owner.viewModel.items.accept(owner.viewModel.data)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // 실시간 검색
        textField.rx.text.orEmpty
        // 아래 두 줄이 viewModel로 가야 addbutton을 눌렀을 대 textfieldRelay에 이벤트를 보낼때도
        // 1초를 기다릴 수 있음
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
            .bind(to: viewModel.textFieldRelay)
            .disposed(by: disposeBag)
        
        // addbutton누르면 textfield는 빈 칸으로, item에도 이벤트 전달
        viewModel.addButtonOutput
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.textField.text = ""
                // owner.viewModel.items.accept(owner.viewModel.data) // 전체 다 나오게 하기
                owner.viewModel.textFieldRelay.accept("")
            }
            .disposed(by: disposeBag)
    }
     */
    
    
    // input output pattern 사용 후
    /*
    func bind() {
        let text = addbutton.rx.tap.map{ self.textField.text! }
        var input = ShoppingListViewModel.Input(checkboxButton: nil, favoriteButton: nil, addButton: addbutton.rx.tap.map{self.textField.text!},
                                                searchTextField: textField.rx.text)
        
        let output = viewModel.transform(input: input)
        
        output.tableViewItems
            .drive(todoTableView.rx.items(cellIdentifier: ShoppingListTableViewCell.identifier, cellType: ShoppingListTableViewCell.self)) {(row, element, cell) in
                
                cell.upgradeCell(element) // 위에서 drive를 쓰면 오류나느 이유?
                // 체크박스 누르면 해제...
//                cell.checkboxButton.rx.tap
//                    .map{ row }
//                    .bind(to: input.checkboxButton.)
//                    .disposed(by: cell.disposeBag)
//                // 즐겨찾기 누르면 즐겨찾기
//                cell.starButton.rx.tap
//                    .map{ row }
//                    .bind(to: self.viewModel.favoriteButtonTap)
//                    .disposed(by: cell.disposeBag)

                input.checkboxButton = cell.checkboxButton.rx.tap.map{row}
                input.favoriteButton = cell.starButton.rx.tap.map{row}
            }
            .disposed(by: disposeBag)
        
        todoTableView.rx.itemSelected
            .drive(with: self) { owner, indexPath in
                let vc = EditTodoViewController()
                vc.todoText = owner.viewModel.data[indexPath.row].todoText
                vc.editedTodo = { todo in
                    owner.viewModel.data[indexPath.row].todoText = todo
                    output.tableViewItems.accept(owner.viewModel.data)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        
    }
     */
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
