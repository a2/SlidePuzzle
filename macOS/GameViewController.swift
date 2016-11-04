//
//  GameViewController.swift
//  macOS
//
//  Created by Alexsander Akers on 10/27/16.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import Cocoa
import SpriteKit

class GameViewController: NSViewController {
    let scene = GameScene()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)

        scene.becomeFirstResponder()
    }
}
