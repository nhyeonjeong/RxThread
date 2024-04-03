//
//  EditTodoViewController.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

class EditTodoViewController: UIViewController {
    
    var editedTodo: ((String) -> Void)?
    var todoText: String?
    
    lazy var textField = {
        let view = UITextField()
        view.text = todoText
        view.placeholder = "할 일을 수정하세요"
        return view
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        view.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    @objc func editButtonClicked() {
        dismiss(animated: true)
        // 수정 - 작성되어있지 않으면 토스트
        textField.rx.text.orEmpty
            .bind(with: self) { owner, text in
                if text == "" {
                    owner.view.makeToast("수정할 투두를 입력하세요", duration: 1.0, position: .top)
                } else {
                    owner.editedTodo?(text) // 뭐라도 작성되어있다면 뒤로 dismiss
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
        disposeBag = DisposeBag() // 구독 끊어주기 -> 안 끊어주면 수정버튼을 한 번 눌린 뒤로 textfield에 한글자라도 입력하면 이전 화면으로 돌아감;
    }
    private func setNavigationBar() {
        let button = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(editButtonClicked))
        
        navigationItem.rightBarButtonItem = button
    }
}
