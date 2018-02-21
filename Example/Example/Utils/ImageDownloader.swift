//
//  ImageDownloader.swift
//  Example
//
//  Created by Diego Ernst on 2/20/18.
//  Copyright © 2018 SpatialCanvas. All rights reserved.
//

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
