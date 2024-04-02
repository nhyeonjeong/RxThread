//
//  Extension+UIView.swift
//  SeSACRxThreads
//
//  Created by 남현정 on 2024/04/02.
//

import UIKit

extension UIView {
    static var identifier: String {
        String(describing: self)
    }
    
    func addView(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
}
