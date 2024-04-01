//
//  SearchViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/01.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel {
    
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    lazy var items = BehaviorSubject(value: data)
    let plustButtonSubject = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        plustButtonSubject
            .subscribe(with: self) { owner, _ in
                owner.data.append(["a", "b", "c", "d", "e"].randomElement()!)
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
    }
}
