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
import SpatialCanvas
import UIKit

class ShowRoomsViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    private var restoredRoom: SpatialCanvasRoom?

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SpatialCanvas.shared.run(sceneView: sceneView, with: ARWorldTrackingConfiguration())
        getNearRooms()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpatialCanvas.shared.pause()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createRoomViewController = segue.destination as? CreateRoomViewController {
            createRoomViewController.onRoomCreated = { [weak self] room in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                        self?.performSegue(withIdentifier: "showMain", sender: room)
                    }
                }
            }
        } else if let mainViewController = segue.destination as? MainViewController {
            mainViewController.spatialCanvasRoom = sender as? SpatialCanvasRoom
            mainViewController.onRoomDelete = { [weak self] in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                        self?.getNearRooms()
                    }
                }
            }
        } else if let scanMasterAnchorViewController = segue.destination as? ScanMasterAnchorViewController {
            scanMasterAnchorViewController.referenceImage = sender as? URL
            scanMasterAnchorViewController.onScanReady = { [weak self] _ in
                guard let `self` = self, let room = self.restoredRoom else { return }
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "showMain", sender: room)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func show(rooms: [SpatialCanvasRoomDescriptor]) {
        let alert = UIAlertController(title: "Create a room", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Create new", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "createRoom", sender: nil)
        })
        rooms.forEach { r in
            alert.addAction(UIAlertAction(title: r.name, style: .default) { [weak self] _ in
                self?.restoreRoom(id: r.id)
            })
        }
        present(alert, animated: true, completion: nil)
    }

    private func getNearRooms() {
        startLoading()
        SpatialCanvas.shared.getNearRooms { [weak self] result in
            switch result {
            case let .success(rooms):
                self?.show(rooms: rooms)
                self?.stopLoading()
            case let .error(error):
                self?.show(error: error)
                self?.stopLoading()
            }
        }
    }

    private func restoreRoom(id: String) {
        startLoading()
        SpatialCanvas.shared.restoreRoom(id: id) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case let .success(room):
                self.restoredRoom = room
                self.stopLoading()
                self.performSegue(withIdentifier: "scanMasterAnchor", sender: URL(string: room.masterAnchor.imageUrl))
            case let .error(error):
                self.show(error: error)
                self.stopLoading()
            }
        }
    }

}
