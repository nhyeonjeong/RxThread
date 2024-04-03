//
//  PhoneViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/04.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneViewModel {
    // input
    let inputPhoneTextFieldText = PublishRelay<String>()
    
    // output
    let samplePhone = Observable.just("010")
    let outputNextButton = BehaviorRelay(value: false)
    let outputNextButtonColor = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        inputPhoneTextFieldText
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, text in
                guard let _ = Int(text) else { return }
                if text.count > 10 {
                    owner.outputNextButton.accept(true)
                    owner.outputNextButtonColor.accept(true)
                } else {
                    owner.outputNextButton.accept(false)
                    owner.outputNextButtonColor.accept(false)
                }
            }
            .disposed(by: disposeBag)
    }
}
