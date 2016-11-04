//
//  GameViewController.swift
//  Slider Puzzle
//
//  Created by Alexsander Akers on 10/27/16.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {
    let scene = GameScene()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
