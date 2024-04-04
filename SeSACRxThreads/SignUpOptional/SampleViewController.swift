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
    
    let viewModel = SampleViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    func bind() {
        addButton.rx.tap
            .map{ self.textField.text! }
            .bind(to: viewModel.inputAddButtonTap)
            .disposed(by: disposeBag)
        
        viewModel.items
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
                cell.textLabel?.text = "\(element) @ row \(row)"
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected // indexPath기준
            .map{ $0.row }
            .bind(to: viewModel.inputItemSelected)
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
