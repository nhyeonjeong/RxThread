//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/04.
//

import Foundation
import RxSwift
import RxCocoa
/*
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
*/

// input output pattern
final class BirthdayViewModel {
    struct Input {
        var datePicker: ControlProperty<Date>
    }
    
    struct Output {
        let year: Driver<String>
        let month: Driver<String>
        let day: Driver<String>
        
        let isValid: Driver<Bool>
    }
    let disposeBag = DisposeBag()
    func transform(input: Input) -> Output {
    
        let year = PublishRelay<Int>()
        let month = PublishRelay<Int>()
        let day = PublishRelay<Int>()
        let isValid = PublishRelay<Bool>()
        
        input.datePicker
            .asDriver()
            .drive(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                year.accept(component.year!)
                month.accept(component.month!)
                day.accept(component.day!)
                
                
                // 만 17세 계산
                let today = Calendar.current.startOfDay(for: Date())
                let todayComponent = Calendar.current.dateComponents([.year], from: date, to: today)
                if todayComponent.year! < 17 {
                    isValid.accept(false)
                } else {
                    isValid.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(year: year.map{"\($0)년"}.asDriver(onErrorJustReturn: ""),
                      month: month.map{"\($0)월"}.asDriver(onErrorJustReturn: ""),
                      day: day.map{"\($0)일"}.asDriver(onErrorJustReturn: ""), isValid: isValid.asDriver(onErrorJustReturn: false))
    }
}
