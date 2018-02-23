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

import ARKit
import SceneKit
import SpatialCanvas
import UIKit

class MainViewController: UIViewController {

    var spatialCanvasRoom: SpatialCanvasRoom!
    var onRoomDelete: (() -> Void)?

    @IBOutlet weak var deleteButton: Button!
    private let focusSquare = FocusSquare()
    private let updateQueue = DispatchQueue(label: "updateQueue")
    private var sceneNodes = [String: SCNNode]()
    private var sceneView: VirtualObjectARView! {
        return SpatialCanvas.shared.sceneView as? VirtualObjectARView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        deleteButton.backgroundColor = .lightGray
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)

        sceneView.delegate = self
        spatialCanvasRoom.delegate = self
        SpatialCanvas.shared.delegate = self
    }

    @IBAction func placeButtonDidTouch(_ sender: Button) {
        guard
            let spatialCanvasRoom = spatialCanvasRoom,
            let camera = sceneView.pointOfView,
            let position = focusSquare.lastPosition
        else {
            return
        }
        let eulerAngles: float3 = {
            let camDir = simd_mul(camera.simdTransform, simd_float4(x: 0, y: 0, z: -1, w: 0))
            return simd_float3(0, atan2(-camDir.x, -camDir.z), 0)
        }()
        spatialCanvasRoom.addObject(position: position, eulerAngles: eulerAngles)
    }

    @IBAction func deleteButtonDidTouch(_ sender: Button) {
        let alert = UIAlertController(title: "Delete room?", message: "You will lose all your placed objects.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.deleteRoom()
        })
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Helpers

    private func deleteRoom() {
        startLoading()
        SpatialCanvas.shared.deleteRoom(roomId: spatialCanvasRoom.id) { [weak self] result in
            switch result {
            case .success:
                self?.spatialCanvasRoom = nil
                self?.updateQueue.sync {
                    self?.focusSquare.removeFromParentNode()
                    self?.sceneNodes.values.forEach { $0.removeFromParentNode() }
                }
                DispatchQueue.main.async {
                    self?.onRoomDelete?()
                }
            case let .error(error):
                self?.show(error: error)
            }
        }
    }

    private func drawSceneObject(spatialCanvasObject: SpatialCanvasObject) {
        updateQueue.async { [weak self] in
            guard let `self` = self else { return }
            let position = spatialCanvasObject.position
            let eulerAngles = spatialCanvasObject.eulerAngles
            guard
                let candleScene = SCNScene(named: "art.scnassets/candle.scn"),
                let candle = candleScene.rootNode.childNode(withName: "candle", recursively: true)
                else { return }
            candle.position = SCNVector3(position)
            candle.eulerAngles = SCNVector3(eulerAngles)
            self.sceneNodes[spatialCanvasObject.id] = candle
            self.sceneView.scene.rootNode.addChildNode(candle)
        }
    }

    private func updateSceneObject(spatialCanvasObject: SpatialCanvasObject) {
        guard let node = sceneNodes[spatialCanvasObject.id] else { return }
        let position = spatialCanvasObject.position
        let eulerAngles = spatialCanvasObject.eulerAngles
        updateQueue.async {
            node.position = SCNVector3(position)
            node.eulerAngles = SCNVector3(eulerAngles)
        }
    }

    private func updateFocusSquare() {
        guard spatialCanvasRoom != nil else { return }
        let wp = sceneView.worldPosition(fromScreenPosition: sceneView.center, objectPosition: focusSquare.lastPosition)
        guard let (worldPosition, planeAnchor, _) = wp else {
            updateQueue.async { [weak self] in
                guard let `self` = self else { return }
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            return
        }
        updateQueue.async { [weak self] in
            guard let `self` = self else { return }
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
            let camera = self.sceneView.session.currentFrame?.camera
            if let planeAnchor = planeAnchor {
                self.focusSquare.state = .planeDetected(anchorPosition: worldPosition, planeAnchor: planeAnchor, camera: camera)
            } else {
                self.focusSquare.state = .featuresDetected(anchorPosition: worldPosition, camera: camera)
            }
        }
    }

}

// MARK: - SpatialCanvasDelegate & ARSessionDelegate

extension MainViewController: SpatialCanvasDelegate {

    func spatialCanvas(_ spatialCanvas: SpatialCanvas, didFailWith error: Error) {
        show(error: error)
    }

}

// MARK: - ARSCNViewDelegate

extension MainViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.updateFocusSquare()
        }
    }

}

// MARK: - SpatialCanvasRoomDelegate

extension MainViewController: SpatialCanvasRoomDelegate {

    // called after a room is restored and the master anchor is scanned
    func spatialCanvasRoom(_ spatialCanvasRoom: SpatialCanvasRoom, didFindObjects objects: [SpatialCanvasObject]) {
        objects.forEach { drawSceneObject(spatialCanvasObject: $0) }
    }

    // called after adding an object to the room
    func spatialCanvasRoom(_ spatialCanvasRoom: SpatialCanvasRoom, didAddObject object: SpatialCanvasObject) {
        drawSceneObject(spatialCanvasObject: object)
    }

    // called when the sdk updates object positions
    func spatialCanvasRoom(_ spatialCanvasRoom: SpatialCanvasRoom, didUpdateObjects objects: [SpatialCanvasObject]) {
        objects.forEach { updateSceneObject(spatialCanvasObject: $0) }
    }

}
