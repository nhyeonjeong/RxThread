//
//  Network.swift
//  SeSACRxThreads
//
//  Created by jack on 2024/04/05.
//

import Foundation
import RxSwift
import RxCocoa

enum APIError: Error {
    case invalidURL
    case unknownResponse
    case statusError
}

class BoxOfficeNetwork {
    
    static func sample() {
        // Observable을 만들떄 / 반환값은 Observable<Int>
        // create클로저의 반환값은 Disposable
        // 이런것들이 이떄까지 사용했던 operator를 구현한 거라고 보면 된다.
        let sampeInt = Observable<Int>.create { observer in
            observer.onNext(Int.random(in: 1...100)) // next이벤트로 보내줄래래?? -> 아래에서 계속 next에서만 print가 찍힐 것
            return Disposables.create()
        }
        
        sampeInt
            .subscribe { value in
                print(value)
            } onError: { _ in
                print("Error")
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: DisposeBag()) // 이 함수는 Disposable구조체 안에 구현되어있고 Disposable을 반환해야 해서 이것을 사용해야 했던 것.

    }
//    Observable.just("4") // 4를 방출하고, completed이벤트가 실행, Disposable
    
    static func fetchBoxOfficeData(date: String) -> Observable<Movie> { // 실질적인 데이터를 빼주겠다
//        DisposeBag
        // 이벤트를 직접 만들어,,?ㅜ
        
        let observable = Observable.just("aa") // 내부에 create로 아래처럼 되어있음
        return Observable<Movie>.create { observer in // 항상 Disposable타입으로 반환이 되어야 하기때문에 맞춰서 return 해준다.
            guard let url = URL(string: "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=f5eef3421c602c6cb7ea224104795888&targetDt=\(date)") else {
                observer.onError(APIError.invalidURL) // 에러 이벤트를 던져준다.
                return Disposables.create()
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                print("DataTask Succeed")
                
                if let _ = error { // error가 nil이어야 문제가 없는 것
                    observer.onError(APIError.unknownResponse)
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    observer.onError(APIError.statusError)
                    print("Response Error")
                    return
                }
                
                if let data = data, let appData = try? JSONDecoder().decode(Movie.self, from: data) {
                    observer.onNext(appData)
                    observer.onCompleted() // 중첩 구독을 막기 위해
                } else {
                    print("응답은 왔으나 디코딩 실패")
                    observer.onError(APIError.unknownResponse)
                }
            }.resume()
            
            return Disposables.create()
            
        }.debug()

        
    }
}
