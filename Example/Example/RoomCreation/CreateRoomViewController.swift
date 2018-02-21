//
//  CreateRoomViewController.swift
//  Example
//
//  Created by Diego Ernst on 10/10/17.
//  Copyright © 2017 SpatialCanvas. All rights reserved.
//

import ARKit
import SceneKit
import SpatialCanvas
import UIKit

class CreateRoomViewController: UIViewController {

    var onRoomCreated: ((SpatialCanvasRoom) -> Void)?

    @IBOutlet weak var messageLabel: MessageLabel!
    private let updateQueue = DispatchQueue(label: "updateQueue")
    private var roomName: String?
    private var roomScan = RoomScan()
    private let roomScanNode = SCNNode()

    private var scene: SCNScene! {
        return SpatialCanvas.shared.sceneView?.scene
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        messageLabel.isHidden = true
        scene.rootNode.addChildNode(roomScanNode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRoomName()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scanMasterAnchorViewController = segue.destination as? ScanMasterAnchorViewController {
            scanMasterAnchorViewController.onScanReady = { [weak self] anchorScan in
                guard let `self` = self, let name = self.roomName else { return }
                self.dismiss(animated: true, completion: nil)
                self.createRoom(name: name, roomScan: self.roomScan, masterAnchorScan: anchorScan)
            }
        }
    }

    // MARK: - Helpers

    private func getRoomName() {
        let alert = UIAlertController(title: "New room", message: "Please enter a name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocorrectionType = .default
            textField.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.roomName = alert.textFields?.first?.text
            self?.startScan()
        })
        present(alert, animated: true, completion: nil)
    }

    private func startScan() {
        roomScan.onNewFrame = { [weak self] points in
            self?.showFeaturePoints(scan: points, color: .lightBlue)
        }
        roomScan.onProgress = { [weak self] progress in
            if progress >= 1 {
                self?.roomScan.finish()
                self?.scanMasterAnchor()
                self?.messageLabel.isHidden = true
            }
        }
        messageLabel.isHidden = false
        roomScan.start()
    }

    private func showFeaturePoints(scan: [float3], color: UIColor) {
        updateQueue.async { [weak self] in
            let points = scan.map { SCNVector3Make($0.x, $0.y, $0.z) }
            let source = SCNGeometrySource(vertices: points)
            let indices: [Int32] = (0..<points.count).map { Int32($0) }
            let element = SCNGeometryElement(indices: indices, primitiveType: .point)
            element.maximumPointScreenSpaceRadius = 10
            let geometry = SCNGeometry(sources: [source], elements: [element])
            geometry.firstMaterial?.diffuse.contents = color
            self?.roomScanNode.geometry = geometry
        }
    }

    private func scanMasterAnchor() {
        roomScanNode.removeFromParentNode()
        performSegue(withIdentifier: "scanMasterAnchor", sender: nil)
    }

   private func createRoom(name: String, roomScan: RoomScan, masterAnchorScan: MasterAnchorScan) {
        startLoading()
        SpatialCanvas.shared.createRoom(name: name, room: roomScan, masterAnchor: masterAnchorScan) { [weak self] result in
            self?.stopLoading()
            switch result {
            case let .success(room):
                self?.onRoomCreated?(room)
            case let .error(error):
                self?.show(error: error)
            }
        }
    }

}
