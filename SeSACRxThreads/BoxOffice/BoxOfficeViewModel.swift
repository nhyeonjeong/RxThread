//
//  BoxOfficeViewModel.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/06.
//

import Foundation
import RxSwift
import RxCocoa

final class BoxOfficeViewModel {
    let disposeBag = DisposeBag()
    // 최근 검색한 것->컬렉션뷰에 들어가고 있음
    // 검색결과를 담는 배열은 없어도 되는 이유는 네트워크 통신을 할 때마다 전체가 바뀜
    // 최근 선택한 컬렉션뷰는 append
    var recent: [String] = []
    
    struct Input {
        let searchText: ControlProperty<String?> // 글자를 가지고 오는건데 이벤트를 받기만 하면 된다. 그래서 ControlProperty로 하겠다
        
        // 셀에서 선택했을 때 들어오는 String - 이벤트를 보내기만 하니까 Observable로 해보겠다
        // 수정)->근데 셀을 클릭했을 때 이벤트를 여리고 보내줘야 하는데 Observable이라 받지를 못함
        // PublishSubject가 맞는듯??..
        let recentText: PublishSubject<String>
        let searchButtonTap: ControlEvent<Void> // ControlEvent도 Observable의 일종. 이벤트를 발생하고 받지는 않으니까 ControlEvenet!
        
    }
    
    struct Output {
        // 검색버튼을 클릭하면 tableview에 나타낼 observer
        let movie: PublishSubject<[DailyBoxOfficeList]> // 네트워크 통신과 결합할 요소라 relay보다 subject가 더 낫다(error, completed등의 이벤트를 뱉어야 될 수도 있으니까?..) / 이벤트를 전달받아야되니까 Subject
        
        // 컬렉션뷰 이벤트
        // output에 보낼때는 Observable의 역할만 하는 것으로 보내도 될듯? -> Driver의 타입으로 바꿔주기
        let recent: Driver<[String]>
        
    }
    
    func transform(input: Input) -> Output {
        // 이벤트 전달을 위해 미리 만들어서 나중에 반환하면 되니까 transform함수에 또 만든다.
        let boxOfficeList = PublishSubject<[DailyBoxOfficeList]>()
        
        // 뷰모델에서 이벤트를 받고 뷰컨에서 구독을 해야하니까 relay(UI를 그리는 거니까 Relay)
        let recentList = BehaviorRelay(value: recent)
        
        // 검색버큰 클릭하면?
        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText.orEmpty) // 검색한 글자를 가져온다
            .map {
                guard let intText = Int($0) else {return 20240101}
                return intText
            }
            .map{String($0)}
            .flatMap {
                BoxOfficeNetwork.fetchBoxOfficeData(date: $0)
            }
            .subscribe(with: self) { owner, value in
                let data = value.boxOfficeResult.dailyBoxOfficeList
                boxOfficeList.onNext(data) // tableView에 이벤트 전달~
            } onError: { _, _ in
                print("error")
            } onCompleted: { _ in
                print("completed")
            } onDisposed: { _ in
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        // 들어온 글자를 컬렉션뷰로 보여주기 위해 이벤트 전달
        input.recentText
            .subscribe(with: self) { owner, value in
                owner.recent.append(value)
                // 컬렉션뷰 이벤트 보내기
                recentList.accept(owner.recent)
            }
            .disposed(by: disposeBag)
        
        return Output(movie: boxOfficeList, recent: recentList.asDriver())
    }
}

