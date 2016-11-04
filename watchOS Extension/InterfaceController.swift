//
//  InterfaceController.swift
//  watchOS Extension
//
//  Created by Alexsander Akers on 10/27/16.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import Foundation
import WatchKit

class InterfaceController: WKInterfaceController {
    let scene = GameScene()

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        skInterface.presentScene(scene)
        skInterface.preferredFramesPerSecond = 30
    }

    @IBAction func shuffle() {
        scene.shuffle()
    }

    @IBAction func touched(_ gesture: WKTapGestureRecognizer) {
        let point: CGPoint = {
            let location = gesture.locationInObject()
            let size = scene.size

            var bounds = gesture.objectBounds()
            bounds.origin.y = bounds.size.height - bounds.size.width
            bounds.size.height = bounds.size.width

            return CGPoint(
                x: (location.x - bounds.origin.x) / bounds.size.width * size.width,
                y: size.height - (location.y - bounds.origin.y) / bounds.size.height * size.height
            )
        }()
        scene.movePieces(at: point)
    }

    @IBAction func swipeUp() {
        scene.movePieces(.up)
    }

    @IBAction func swipeDown() {
        scene.movePieces(.down)
    }

    @IBAction func swipeLeft() {
        scene.movePieces(.left)
    }

    @IBAction func swipeRight() {
        scene.movePieces(.right)
    }
}
