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
    
    struct Input {
        let searchText: ControlProperty<String?> // 글자를 가지고 오는건데 이벤트를 받기만 하면 된다. 그래서 ControlProperty로 하겠다
        let recentText: Observable<String> // 셀에서 선택했을 때 들어오는 String - 이벤트를 받기만 하니까 Observable로 해보겠다
        let searchButtonTap: ControlEvent<Void> // ControlEvent도 Observable의 일종. 이벤트를 발생하고 받지는 않으니까 ControlEvenet!
        
    }
    
    struct Output {
        // 검색버튼을 클릭하면 tableview에 나타낼 observer
        let movie: PublishSubject<[DailyBoxOfficeList]> // 네트워크 통신과 결합할 요소라 relay보다 subject가 더 낫다(error, completed등의 이벤트를 뱉어야 될 수도 있으니까?..) / 이벤트를 전달받아야되니까 Subject
        
    }
    
    func transform(input: Input) -> Output {
        // 이벤트 전달을 위해 미리 만들어서 나중에 반환하면 되니까 transform함수에 또 만든다.
        let boxOfficeList = PublishSubject<[DailyBoxOfficeList]>()

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
        
        return Output(movie: boxOfficeList)
    }
}

