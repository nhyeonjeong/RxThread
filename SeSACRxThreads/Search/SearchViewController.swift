//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
        return view
    }()
    
    let searchBar = UISearchBar()
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    lazy var items = BehaviorSubject(value: data)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        configure()
        bind()
        setSearchController()
    }
    
    func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                
                cell.appNameLabel.text = "테스트 \(element)"
                cell.appIconImageView.backgroundColor = .systemBlue
                
                // 받기 누르면 화면 전환
                cell.downloadButton.rx.tap
                    .bind(with: self) { owner, _ in
                        print("화면전환")
                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
                        
                    }
                    .disposed(by: cell.disposeBag) // cell의 disposeBag
            }
            .disposed(by: disposeBag)
        
        // 셀 눌렀을 때 삭제
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .bind(with: self) { owner, value in
                owner.data.remove(at: value.0.row)
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
        
        // 서치바 텍스트가 포함된 결과를 테이블뷰에 보여주기(filter)
        searchBar.rx.text.orEmpty // 옵셔널 벗기고~
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in // value는 searchBar의 텍스트
                print("실시간 검색 \(value)")
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value)}
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
        // 키보드 return을 눌러도 서치
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                print("검색 버튼 클릭(return) \(value)")
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
    }
    func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        let sample = ["a", "b", "C", "d", "e"]
        data.append(sample.randomElement()!)
        items.onNext(data)
    }
    
    func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

}
