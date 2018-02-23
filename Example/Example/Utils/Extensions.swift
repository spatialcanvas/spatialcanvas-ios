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

import SceneKit
import UIKit

extension UIViewController {

    func show(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func startLoading() {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.color = .lightBlue
        indicator.tag = 55
        let width = view.bounds.width
        let height = view.bounds.height
        let size = CGFloat(100)
        indicator.frame = CGRect(x: (width - size) / 2, y: (height - size) / 2, width: size, height: size)
        indicator.startAnimating()
        indicator.layer.shadowColor = UIColor.black.cgColor
        indicator.layer.shadowOpacity = 0.7
        indicator.layer.shadowOffset = CGSize.zero
        indicator.layer.shadowRadius = 5
        view.addSubview(indicator)
    }

    func stopLoading() {
        guard let indicator = view.viewWithTag(55) as? UIActivityIndicatorView else { return }
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }

}

extension UIImageView {

    func set(image: UIImage) {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.image = image
            },
            completion: nil
        )
    }

    func set(imageUrl: URL) {
        ImageDownloader.shared.download(from: imageUrl) { [weak self] image, error in
            if let image = image {
                self?.set(image: image)
            }
        }
    }

}

extension float4x4 {

    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }

}

extension UIColor {

    class var lightBlue: UIColor {
        return UIColor(red: 51.0 / 255.0, green: 204.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    class var warmGrey: UIColor {
        return UIColor(white: 149.0 / 255.0, alpha: 1.0)
    }

}
