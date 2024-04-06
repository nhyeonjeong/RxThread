//
//  BoxOfficeViewController.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/06.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BoxOfficeViewController: UIViewController {

    let tableView = UITableView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    let searchBar = UISearchBar()
    let disposeBag = DisposeBag()
    let viewModel = BoxOfficeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bind()
        
    }
    
    func bind() {

        // input도 미리 recentText는 하나 만들어서 보내주기
        // 셀에서 선택했을 때 글자이다
        // itemSelected에서 이벤트를 보내줘야 하니까 만들어준다.
        // 뷰모델에서도 Input에 작성했던 것처럼 Observable<String>타입을 만들기 위해 create사용
        // 수정)-> publishSubject가 맞는 것 같아서 수정
//        let recentText = Observable<String>.create { observer in
//            return Disposables.create()
//        }
        let recentText = PublishSubject<String>()
        
        let input = BoxOfficeViewModel.Input(searchText: searchBar.rx.text,
                                              recentText: recentText,
                                              searchButtonTap: searchBar.rx.searchButtonClicked)
        
        let output = viewModel.transform(input: input)
        // 뷰모델에서 네트워크 통신 후 뷰모델 그리기
        output.movie
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) {(row, element, cell) in
                cell.appNameLabel.text = element.movieNm
                cell.downloadButton.setTitle(element.openDt, for: .normal)
            }
            .disposed(by: disposeBag)
        
        // 컬렉션뷰에 보여질 선택한 글자 이벤트 보내기
        Observable.zip(tableView.rx.modelSelected(DailyBoxOfficeList.self),
                       tableView.rx.itemSelected)
        .map{ $0.0.movieNm }
        .subscribe(with: self) { owner, value in
            print(value)
            recentText.onNext(value)
        }
        .disposed(by: disposeBag)
        
        // 컬렉션뷰를 그리자(넘어오는 것은 Observable)
        output.recent
            .drive(collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.identifier, cellType: MovieCollectionViewCell.self)) { (row, element, cell) in
                cell.label.text = "\(element) @ row \(row) \(element)"
            }
            .disposed(by: disposeBag)
    }
    
    func configure() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        navigationItem.titleView = searchBar
        
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.backgroundColor = .green
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.backgroundColor = .red
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
    }

    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
}

