//
//  ShoppingListTableViewCell.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ShoppingListTableViewCell: UITableViewCell {
    let backView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    let checkboxButton = {
        let view = UIButton()
        view.tintColor = .black
        view.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        return view
    }()
    let todoLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        return view
    }()
    
    let starButton = {
        let view = UIButton()
        view.tintColor = .black
        view.setImage(UIImage(systemName: "star"), for: .normal)
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        backView.addView([checkboxButton, todoLabel, starButton])
        addSubview(backView)
    }
    
    private func configureConstraints() {
        backView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.verticalEdges.equalToSuperview().inset(2)
        }
        checkboxButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        }
        todoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkboxButton.snp.trailing).offset(10)
        }
        starButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.leading.greaterThanOrEqualTo(todoLabel.snp.trailing).offset(10)
        }
    }
    
    func upgradeCell(_ element: ShoppingListModel) {
        let checkImage = element.isChecked ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "checkmark.square")
        checkboxButton.setImage(checkImage, for: .normal)
        
        let favoriteImage = element.isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        starButton.setImage(favoriteImage, for: .normal)
        todoLabel.text = element.todoText
    }

}
