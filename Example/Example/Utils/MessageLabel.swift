//
//  MessageLabel.swift
//  Example
//
//  Created by Diego Ernst on 2/20/18.
//  Copyright © 2018 SpatialCanvas. All rights reserved.
//

import UIKit

class MessageLabel: UILabel {

    private var animationSet = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
        guard !animationSet else { return }
        startAnimating()
        animationSet = true
    }

    private func startAnimating() {
        alpha = 0.3
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .beginFromCurrentState], animations: {
            self.alpha = 1
        }, completion: nil)
    }

    private func setup() {
        font = .boldSystemFont(ofSize: 20)
        textColor = .black
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
    }

}
