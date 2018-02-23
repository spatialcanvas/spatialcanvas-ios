/*
 * Copyright 2017 SpatialCanvas
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
