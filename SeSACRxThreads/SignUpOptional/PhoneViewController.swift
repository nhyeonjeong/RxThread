//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

// 1. 화면 진입 시 010을 텍스트필드에 바로 띄우기
// 2. 텍스트필드에는 숫자만 들어갈 수 있고, 10자 이상이어야 함
// 3. 조건이 맞지 않는 경우 PasswordController처럼 로직 구현
class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    let viewModel = PhoneViewModel()
    //rx
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        bind()
    }
    /*
    func bind() {
        viewModel.samplePhone
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .bind(to: viewModel.inputPhoneTextFieldText)
            .disposed(by: disposeBag)
        
        viewModel.outputNextButton
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.outputNextButtonColor
            .bind(with: self, onNext: { owner, value in
                owner.nextButton.backgroundColor = value ? .systemGreen : .gray
            })
            .disposed(by: disposeBag)
        
        // 다음화면으로
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    */
    
    // input output pattern
    func bind() {
    
        nextButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        let input = PhoneViewModel.Input(textfield: phoneTextField.rx.text)
        
        let output = viewModel.transform(input: input)
        output.isValid
            .asDriver()
            .drive(with: self) { owner, value in
                owner.nextButton.isEnabled = value
                owner.nextButton.backgroundColor = value ? .systemGreen : .gray
            }
            .disposed(by: disposeBag)
        output.sampleText
            .drive(phoneTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
