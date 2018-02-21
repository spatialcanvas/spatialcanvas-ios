//
//  ScanMasterAnchorViewController.swift
//  PostAR
//
//  Created by Diego Ernst on 12/5/17.
//  Copyright © 2017 SpatialCanvas SRL. All rights reserved.
//

import SceneKit
import SpatialCanvas
import UIKit

class ScanMasterAnchorViewController: UIViewController {

    var referenceImage: URL?
    var onScanReady: ((MasterAnchorScan) -> Void)?

    @IBOutlet weak var scanButton: Button!
    private var rectangleLayer: CAShapeLayer?
    private var showingPopup = false {
        didSet {
            scanButton.isHidden = showingPopup
        }
    }
    private lazy var scanner: MasterAnchorScan = { [weak self] in
        return MasterAnchorScan(visualizer: self)
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        scanner.start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showingPopup = true
        if let referenceImage = referenceImage {
            PopupView()
                .title("Look for this object in the room.")
                .imageUrl(referenceImage)
                .action("Ok") { [weak self] in
                    self?.showingPopup = false
                }
                .present(in: self)
        } else {
            PopupView()
                .title("Scan a starting object. Look for rectangled surfaces like frames.")
                .image(#imageLiteral(resourceName: "scanExample"))
                .action("Ok") { [weak self] in
                    self?.showingPopup = false
                }
                .present(in: self)
        }
    }

    @IBAction func scanButtonDidTouch(_ sender: UIButton) {
        scanner.scan()
    }

}

// MARK: - ImageSearchVisualizer

extension ScanMasterAnchorViewController: ImageSearchVisualizer {

    func on(rectangle: Rectangle2D) {
        guard !showingPopup else { return }
        rectangleLayer?.removeFromSuperlayer()
        let points = [rectangle.topLeft, rectangle.topRight, rectangle.bottomRight, rectangle.bottomLeft]
        rectangleLayer = drawPolygon(points, color: .lightBlue)
        view.layer.addSublayer(self.rectangleLayer!)
    }

    func on(width: Double, height: Double) {

    }

    func onNoRectangle() {
        onReset()
    }

    func onReset() {
        rectangleLayer?.removeFromSuperlayer()
        rectangleLayer = nil
    }

    private func drawPolygon(_ points: [CGPoint], color: UIColor) -> CAShapeLayer {
        guard !points.isEmpty else { return CAShapeLayer() }
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = 4
        let path = UIBezierPath()
        path.move(to: points.last!)
        points.forEach { point in
            path.addLine(to: point)
        }
        layer.path = path.cgPath
        return layer
    }

    func on(image: ImageWithMetrics) {
        if referenceImage == nil {
            showingPopup = true
            onReset()
            PopupView()
                .title("Looking good?")
                .image(image.image)
                .action("No", color: .warmGrey) { [weak self] in
                    self?.showingPopup = false
                }
                .action("Yes") { [weak self] in
                    guard let `self` = self else { return }
                    self.onScanReady?(self.scanner)
                    self.showingPopup = false
                }
                .present(in: self)
        } else {
            onScanReady?(scanner)
        }
    }

}
