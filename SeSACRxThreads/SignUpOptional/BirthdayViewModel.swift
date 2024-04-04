//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/04.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    // input
    let inputDatePicker = PublishRelay<Date>()
    // output
    let outputYear = PublishRelay<Int>()
    let outputMonth = PublishRelay<Int>()
    let outputDay = PublishRelay<Int>()
    let outputInfoValidation = PublishRelay<Bool>()
    let outputNextButton = PublishRelay<Bool>()
    let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        inputDatePicker
            .asDriver(onErrorJustReturn: .now)
            .drive(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                owner.outputYear.accept(component.year!)
                owner.outputMonth.accept(component.month!)
                owner.outputDay.accept(component.day!)
                
            
                // 만 17세 계산
                let today = Calendar.current.startOfDay(for: Date())
                let todayComponent = Calendar.current.dateComponents([.year], from: date, to: today)
                if todayComponent.year! < 17 {
                    owner.outputInfoValidation.accept(false)
                    owner.outputNextButton.accept(false)
                } else {
                    owner.outputInfoValidation.accept(true)
                    owner.outputNextButton.accept(true)
                }
            }
            .disposed(by: disposeBag)
    }
}
