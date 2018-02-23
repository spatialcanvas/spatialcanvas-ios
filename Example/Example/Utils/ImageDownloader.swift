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

class ImageDownloader {

    static let shared = ImageDownloader()
    private let downloadQueue = DispatchQueue(label: "downloadQueue")

    func download(from url: URL, completion: ((UIImage?, Error?) -> Void)?) {
        downloadQueue.async {
            let result: (UIImage?, Error?)
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    throw NSError()
                }
                result = (image, nil)
            } catch let error {
                result = (nil, error)
            }
            DispatchQueue.main.async {
                completion?(result.0, result.1)
            }
        }
    }

}
