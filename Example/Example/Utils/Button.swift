//
//  Button.swift
//  Example
//
//  Created by Diego Ernst on 2/20/18.
//  Copyright © 2018 SpatialCanvas. All rights reserved.
//

import UIKit

class Button: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 5
        clipsToBounds = true
        backgroundColor = .lightBlue
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 15)
    }

}
