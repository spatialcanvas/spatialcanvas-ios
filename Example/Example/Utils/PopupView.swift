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

class PopupView: UIView {

    private let titleLabel = UILabel()
    private let actionButton = Button()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let actionButtons = UIStackView()
    private var callbacks = [() -> Void]()

    init() {
        super.init(frame: .infinite)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func title(_ title: String) -> PopupView {
        titleLabel.text = title
        return self
    }

    func action(_ action: String, color: UIColor = .lightBlue, callback: @escaping () -> Void) -> PopupView {
        let button = Button(type: .system)
        button.backgroundColor = color
        button.setTitle(action, for: .normal)
        button.addTarget(self, action: #selector(PopupView.actionDidTouch(action:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 155)
        widthConstraint.priority = .defaultHigh
        button.addConstraint(widthConstraint)
        button.addConstraint(button.heightAnchor.constraint(equalToConstant: 50))
        actionButtons.addArrangedSubview(button)
        callbacks.append(callback)
        return self
    }

    @objc func actionDidTouch(action: Button) {
        guard let index = actionButtons.arrangedSubviews.index(of: action) else {
            return
        }
        animate(toY: superview?.bounds.height ?? 0, damping: 1.5) {
            self.callbacks[index]()
            self.removeFromSuperview()
        }
    }

    func image(_ image: UIImage) -> PopupView {
        imageView.image = image
        return self
    }

    func imageUrl(_ url: URL) -> PopupView {
        imageView.set(imageUrl: url)
        return self
    }

    func present(in viewController: UIViewController) {
        frame = CGRect(
            x: viewController.view.bounds.width * 0.1,
            y: viewController.view.bounds.height,
            width: viewController.view.bounds.width * 0.8,
            height: 450
        )
        viewController.view.addSubview(self)
        animate(toY: (viewController.view.bounds.height - self.frame.height) * 0.5, damping: 0.6)
    }

    private func animate(toY y: CGFloat, damping: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: {
                var newFrame = self.frame
                newFrame.origin.y = y
                self.frame = newFrame
            },
            completion: { _ in completion?() }
        )
    }

    private func setup() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 10
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addConstraints([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.addConstraints([
            imageView.widthAnchor.constraint(equalToConstant: 160),
            imageView.heightAnchor.constraint(equalToConstant: 244),
        ])
        actionButtons.axis = .horizontal
        actionButtons.distribution = .fillEqually
        actionButtons.alignment = .center
        actionButtons.spacing = 15
        actionButtons.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        actionButtons.isLayoutMarginsRelativeArrangement = true
        titleLabel.addConstraint(titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50))
        titleLabel.numberOfLines = 0
        [titleLabel, imageView, actionButtons].forEach {
            stackView.addArrangedSubview($0)
        }
    }

}
