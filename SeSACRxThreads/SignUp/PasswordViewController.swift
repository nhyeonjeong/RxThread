//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PasswordViewController: UIViewController {
   
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")

    let disposeBag = DisposeBag()
//    lazy var passwordObservable = Observable.just(passwordTextField.text)
    let nextButtonObservable = BehaviorSubject(value: false) // 이벤트를 주기만?
    let nextButtonColor = BehaviorSubject(value: UIColor.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
         
        
        // textfield.text의 글자수에 따른 nextButton.isEnabled변경
        passwordTextField.rx.text
            .bind(with: self) { owner, text in
                guard let text else { return }
                if text.count < 16 && text.count > 6 {
                    owner.nextButtonObservable.onNext(true)
                    owner.nextButtonColor.onNext(.systemGreen)
                } else {
                    owner.nextButtonObservable.onNext(false)
                    owner.nextButtonColor.onNext(.gray)
                }
            }
            .disposed(by: disposeBag)
        
        // nextButton 컬러 변경
        nextButtonColor
            .bind(to: nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // nextButton.isEnabled변경
        nextButtonObservable
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 다음 화면으로 넘기기
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                
                owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
                
            }
            .disposed(by: disposeBag)
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(PhoneViewController(), animated: true)
    }
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
