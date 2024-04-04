//
//  ShoppingListViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/03.
//

import Foundation
import RxSwift
import RxCocoa

// input output pattern 전
/*
final class ShoppingListViewModel {
    var data: [ShoppingListModel] = []
    let disposeBag = DisposeBag()
    
    // input
    // 체크박스 버튼 눌렀을 때
    let checkboxButtonTap: PublishRelay<Int> = PublishRelay()
    // 즐겨찾기 버튼 눌렀을 때
    let favoriteButtonTap: PublishRelay<Int> = PublishRelay()
    // 추가 버튼 눌렀을 때
    let addButtonTap: PublishRelay<String> = PublishRelay()
    let textFieldRelay = PublishRelay<String>()
    
    // output
    lazy var items = BehaviorRelay(value: data)
    let addButtonOutput = PublishRelay<Void>()
    
    init() {
        bind()
    }
    
    private func bind() {
        checkboxButtonTap
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self) { owner, row in
                print("click checkbox")
                owner.data[row].isChecked.toggle()
                owner.data.remove(at: row)
                owner.items.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        favoriteButtonTap
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self) { owner, row in
                print("click starbutton")
                owner.data[row].isFavorite.toggle()
                owner.items.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        addButtonTap
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, text in
                print("addbutton")
                let newData = ShoppingListModel(isChecked: false, todoText: text, isFavorite: false)
                owner.data.append(newData)
                owner.items.accept(owner.data)
                // 검색글자 지우기
                owner.addButtonOutput.accept(())
            }
            .disposed(by: disposeBag)
        
        textFieldRelay
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, text in
                let result = text == "" ? owner.data : owner.data.filter{ $0.todoText.contains(text)}
                owner.items.accept(result)
            }
            .disposed(by: disposeBag)
    }
}
*/

// 후
final class ShoppingListViewModel {
    var data: [ShoppingListModel] = []
    let disposeBag = DisposeBag()
    struct Input {
        let checkboxButton: ControlEvent<Int>
        let favoriteButton: ControlEvent<Int>
        let addButton: ControlEvent<String>
        let searchTextField: ControlProperty<String>
    }
    
    struct Output {
        let tableViewItems: Driver<[ShoppingListModel]>
        let addButton: Driver<Void>
    }
    
//    func transform(input: Input) -> Output {
//        
//    }
    
    
}
