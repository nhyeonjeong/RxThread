//
//  SampleViewController.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SampleViewController: UIViewController {

    let textField = UITextField()
    let addButton = {
        let view = UIButton()
        view.setTitle("추가", for: .normal)
        return view
    }()
    let tableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return view
    }()
    
    let disposeBag = DisposeBag()
//    var tableList: [String] = []
    let tableListSubject = BehaviorSubject(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    func bind() {
        addButton.rx.tap
            .bind(with: self) { owner, _ in
                guard let text = owner.textField.text else {
                    return
                }
                // ?
                do {
                    var list = try owner.tableListSubject.value()
                    list.append(text)
                    owner.tableListSubject.onNext(list)
                } catch {
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        tableListSubject
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                print("w4oitw;r")
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
                cell.textLabel?.text = "\(element) @ row \(row)"
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected // indexPath기준
            .bind(with: self, onNext: { owner, indexPath in
                print(indexPath)
                do {
                    var list = try owner.tableListSubject.value()
                    list.remove(at: indexPath.row)
                    owner.tableListSubject.onNext(list)
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)
    }
    func configureHierarchy() {
        view.addSubview(textField)
        view.addSubview(addButton)
        view.addSubview(tableView)
    }
    
    func configureConstraints() {
        textField.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            
            make.height.equalTo(40)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(40)
            make.leading.equalTo(textField.snp.trailing).offset(8)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureView() {
        view.backgroundColor = .white
        addButton.backgroundColor = .systemCyan
        tableView.backgroundColor = .systemPink
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 10
    }
}
