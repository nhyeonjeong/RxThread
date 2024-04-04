//
//  SampleViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/04.
//

import Foundation
import RxSwift
import RxCocoa

final class SampleViewModel {
    var data: [String] = []
    // Input
    let inputAddButtonTap = PublishSubject<String>()
    let inputItemSelected = PublishSubject<Int>() // row때문에 int타입
    
    // output
    lazy var items = BehaviorSubject(value: data)
    
    let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        inputAddButtonTap
            .bind(with: self) { owner, text in
                owner.data.append(text)
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
        
        inputItemSelected
            .bind(with: self) { owner, row in
                owner.data.remove(at: row)
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
    }
}
