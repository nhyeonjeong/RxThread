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
    var disposeBag2 = DisposeBag()
    
    // 다른 함수에서도 사용하기 위해서 그냥 전역으로 뻈다
    lazy var tableViewItems = BehaviorRelay<[ShoppingListModel]>(value: data) // 이벤트를 받아야하니까, UI에 최적화위해 Relay
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
        
        // addButton을 눌러서 textfield가 ""이 되면 ""으로 다시 검색하는 이벤트를 받아야 한다.
        // 수정) ControlProperty에서 PublishSubject로 변경
//        let searchTextField = PublishRelay<String?>()
        
        // 체크박스 눌렀을 때
        input.checkboxButton
            .subscribe(with: self, onNext: { owner, row in
                owner.data.remove(at: row)
                owner.tableViewItems.accept(owner.data)
            })
            .disposed(by: disposeBag)
        
        // 즐겨찾기 눌렀을 때
        input.favoriteButton
            .subscribe(with: self, onNext: { owner, row in
                owner.data[row].isFavorite.toggle()
                owner.tableViewItems.accept(owner.data)
            })
            .disposed(by: disposeBag)
        
        // 추가 버튼 눌렀을 때
        input.addButton
            .withLatestFrom(input.searchTextField.orEmpty) // 받아온 Textfield글자 옵셔널 벗기기
            .subscribe(with: self) { owner, text in
                owner.disposeBag2 = DisposeBag() // 끊기,,? 되나?
                
                let newData = ShoppingListModel(isChecked: false, todoText: text, isFavorite: false)
                owner.data.append(newData)
                owner.tableViewItems.accept(owner.data)
//
//                // 추가하면 textfield는 ""이 되니까 ""로 다시 검색해야함
//                searchTextField.accept("")
//                
                // 다시 disposeBag2를 연결
                owner.subscribeSearchTextField(input.searchTextField)
            }
            .disposed(by: disposeBag)
        
//        searchTextField
//            .asDriver(onErrorJustReturn: "")
//            .dri
//        
        
        subscribeSearchTextField(input.searchTextField)

        return Output(tableViewItems: tableViewItems)
    }
    func subscribeSearchTextField(_ observable: ControlProperty<String?>) {
        // 실시간 검색
        observable.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance) // 멈추고 1초 뒤에 검색
            .distinctUntilChanged() // 바로 이전과 겹치면 검색안하기
            .subscribe(with: self) { owner, text in
                let result = text == "" ? owner.data : owner.data.filter{ $0.todoText.contains(text)}
                owner.tableViewItems.accept(result)
            }
            .disposed(by: disposeBag2)
        
    }
    
}
