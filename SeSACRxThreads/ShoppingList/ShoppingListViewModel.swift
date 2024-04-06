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
        // 셀이 있어야 클릭도 되는 것. 이벤트를 받기도 하니까 subject (row도 같이 가지고 온다)
        var checkboxButton: PublishSubject<Int>
        var favoriteButton: PublishSubject<Int>
        let addButton: ControlEvent<Void>
        let searchTextField: ControlProperty<String?>
    }
    
    struct Output {
        // 이벤트를 받을 일 없으니까 Drive(Observable)
        // 수정) -> 뷰컨쪽에서 화면전환했다가 다시 돌아올 때 이벤트를 전달하고 있으므로 받으려면 BehaviorRelay가 나을듯
        let tableViewItems: BehaviorRelay<[ShoppingListModel]>
    }
    
    func transform(input: Input) -> Output {
        let tableViewItems = BehaviorRelay<[ShoppingListModel]>(value: data) // 이벤트를 받아야하니까, UI에 최적화위해 Relay
        // 체크박스 눌렀을 때
        input.checkboxButton
            .subscribe(with: self, onNext: { owner, row in
                owner.data.remove(at: row)
                tableViewItems.accept(owner.data)
            })
            .disposed(by: disposeBag)
        
        // 즐겨찾기 눌렀을 때
        input.favoriteButton
            .subscribe(with: self, onNext: { owner, row in
                owner.data[row].isFavorite.toggle()
                tableViewItems.accept(owner.data)
            })
            .disposed(by: disposeBag)
        
        // 추가 버튼 눌렀을 때
        input.addButton
            .withLatestFrom(input.searchTextField.orEmpty) // 받아온 Textfield글자 옵셔널 벗기기
            .subscribe(with: self) { owner, text in
                let newData = ShoppingListModel(isChecked: false, todoText: text, isFavorite: false)
                owner.data.append(newData)
                tableViewItems.accept(owner.data)
                
            }
            .disposed(by: disposeBag)
        
        // 실시간 검색
        input.searchTextField.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance) // 멈추고 1초 뒤에 검색
            .distinctUntilChanged() // 바로 이전과 겹치면 검색안하기
            .subscribe(with: self) { owner, text in
                let result = text == "" ? owner.data : owner.data.filter{ $0.todoText.contains(text)}
                tableViewItems.accept(result)
            }
            .disposed(by: disposeBag)
        
        return Output(tableViewItems: tableViewItems)
    }
    
    
}
