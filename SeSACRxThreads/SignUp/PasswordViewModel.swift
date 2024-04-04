//
//  PasswordViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/03.
//

import Foundation
import RxSwift
import RxCocoa

/*
final class PasswordViewModel {
    
    // input
    // textfield가 입력될 때마다
    let textFieldRelay = PublishRelay<String>()
    
    // output
    let outputNextButtonIsEnabled = BehaviorRelay(value: false) // 이벤트를 주기만?
    // import UIKit이 안 되어 있어서 UIColor타입으로 할 수 없었다
    let outputNextButtonColor = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        textFieldRelay
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, text in
                if text.count < 16 && text.count > 6 {
                    owner.outputNextButtonIsEnabled.accept(true)
                    owner.outputNextButtonColor.accept(true)
                } else {
                    owner.outputNextButtonIsEnabled.accept(false)
                    owner.outputNextButtonColor.accept(false)
                }
            }
            .disposed(by: disposeBag)
    }
}
*/

// input output pattern
final class PasswordViewModel {
    struct Input {
        let textfield: ControlProperty<String?>
    }
    
    struct Output {
        let isValid: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let isValid = input.textfield
            .orEmpty
            .map{ $0.count < 16 && $0.count > 6 }
            .asDriver(onErrorJustReturn: false) // 에러가 발생하면 클릭되지 않도록
        
        return Output(isValid: isValid)
    }
    
    
}
