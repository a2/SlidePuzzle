//
//  GameScene.swift
//  Slider Puzzle
//
//  Created by Alexsander Akers on 10/27/16.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import SpriteKit

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
    typealias SKFont = UIFont
#elseif os(macOS)
    import AppKit
    typealias SKFont = NSFont
#endif

#if os(watchOS)
    import WatchKit
    // <rdar://problem/26756207> SKColor typealias does not seem to be exposed on watchOS SpriteKit
    typealias SKColor = UIColor
#endif

enum Direction: UInt16 {
    case up    = 126
    case down  = 125
    case left  = 123
    case right = 124
}

struct Location: Equatable, Hashable {
    var row: Int
    var column: Int

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }

    var hashValue: Int {
        return row.hashValue &* 31 &+ column.hashValue
    }
}

class GameScene: SKScene {
    fileprivate var pieces = [SKNode]()
    fileprivate var emptyLocation = Location(row: -1, column: -1)
    fileprivate var pieceLocations = [Location: SKNode]()

    override init() {
        super.init(size: CGSize(width: 400, height: 400))
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    fileprivate func commonInit() {
        scaleMode = .aspectFit
    }

    fileprivate func configureScene() {
        let fontName = SKFont.boldSystemFont(ofSize: 32).fontName
        for i in 0 ... 14 {
            let piece = SKEffectNode()
            piece.shouldRasterize = true
            piece.name = "piece\(i + 1)"

            let backgroundNode = SKSpriteNode(color: #colorLiteral(red: 0, green: 0.8588235378, blue: 1, alpha: 1), size: CGSize(width: 98, height: 98))
            backgroundNode.name = "background"
            piece.addChild(backgroundNode)

            let textNode = SKLabelNode()
            textNode.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            textNode.fontName = fontName
            textNode.fontSize = 64
            textNode.horizontalAlignmentMode = .center
            textNode.name = "label"
            textNode.text = String(describing: i + 1)
            textNode.verticalAlignmentMode = .center
            piece.addChild(textNode)

            addChild(piece)
            pieces.append(piece)
        }

        shuffle()
    }

    func shuffle() {
        emptyLocation = Location(row: 3, column: 3)
        pieceLocations.removeAll(keepingCapacity: true)

        for (i, piece) in pieces.shuffled().enumerated() {
            piece.position = CGPoint(x: (i % 4) * 100 + 50, y: 350 - (i / 4) * 100)
            pieceLocations[Location(row: i / 4, column: i % 4)] = piece
        }
    }

#if os(watchOS)
    override func sceneDidLoad() {
        super.sceneDidLoad()
        configureScene()
    }
#else
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        configureScene()
    }
#endif

    fileprivate func defaultPosition(for direction: Direction) -> Location? {
        var position = emptyLocation

        switch direction {
        case .up:
            if position.row == 3 {
                return nil
            }

            position.row += 1

        case .down:
            if position.row == 0 {
                return nil
            }

            position.row -= 1

        case .left:
            if position.column == 3 {
                return nil
            }

            position.column += 1

        case .right:
            if position.column == 0 {
                return nil
            }

            position.column -= 1
        }

        return position
    }

    func movePieces(_ direction: Direction, at position: Location? = nil) {
        guard let position = position ?? defaultPosition(for: direction) else {
            return
        }

        var piecesToMove = [(location: Location, piece: SKNode)]()
        for (pieceLocation, piece) in pieceLocations {
            switch direction {
            case .up:
                if position.column == pieceLocation.column && position.row >= pieceLocation.row && pieceLocation.row >= emptyLocation.row {
                    piecesToMove.append((pieceLocation, piece))
                }

            case .down:
                if position.column == pieceLocation.column && position.row <= pieceLocation.row && pieceLocation.row <= emptyLocation.row  {
                    piecesToMove.append((pieceLocation, piece))
                }

            case .left:
                if position.row == pieceLocation.row && position.column >= pieceLocation.column && pieceLocation.column >= emptyLocation.column  {
                    piecesToMove.append((pieceLocation, piece))
                }

            case .right:
                if position.row == pieceLocation.row && position.column <= pieceLocation.column && pieceLocation.column <= emptyLocation.column  {
                    piecesToMove.append((pieceLocation, piece))
                }
            }
        }

        let action: SKAction = {
            switch direction {
            case .up:
                return SKAction.moveBy(x: 0, y: 100, duration: 0.3)

            case .down:
                return SKAction.moveBy(x: 0, y: -100, duration: 0.3)

            case .left:
                return SKAction.moveBy(x: -100, y: 0, duration: 0.3)

            case .right:
                return SKAction.moveBy(x: 100, y: 0, duration: 0.3)
            }
        }()

        var pieceLocationUpdates = [(piece: SKNode, oldLocation: Location, newLocation: Location)]()
        for (oldPieceLocation, piece) in piecesToMove {
            var newPieceLocation = oldPieceLocation

            switch direction {
            case .up:
                newPieceLocation.row -= 1
            case .down:
                newPieceLocation.row += 1
            case .left:
                newPieceLocation.column -= 1
            case .right:
                newPieceLocation.column += 1
            }

            pieceLocationUpdates.append((piece, oldPieceLocation, newPieceLocation))
            piece.run(action)
        }

        if !pieceLocationUpdates.isEmpty {
            for (_, oldLocation, _) in pieceLocationUpdates {
                self.pieceLocations[oldLocation] = nil
            }

            for (piece, _, newLocation) in pieceLocationUpdates {
                self.pieceLocations[newLocation] = piece
            }

            self.emptyLocation = position
        }
    }

    func movePieces(at point: CGPoint) {
        let optionalNode: SKNode? = {
            let nodes = self.nodes(at: point)
            for node in nodes {
                var node: SKNode? = node
                while node != nil {
                    if node!.parent == self {
                        return node
                    }

                    node = node!.parent
                }
            }

            return nil
        }()

        guard let node = optionalNode else {
            return
        }

        let location = Location(
            row: (350 - Int(round(node.position.y))) / 100,
            column: (Int(round(node.position.x)) - 50) / 100
        )
        let direction: Direction

        if location.row == emptyLocation.row {
            if location.column < emptyLocation.column {
                direction = .right
            } else if location.column > emptyLocation.column {
                direction = .left
            } else {
                return
            }
        } else if location.column == emptyLocation.column {
            if location.row < emptyLocation.row {
                direction = .down
            } else if location.row > emptyLocation.row {
                direction = .up
            } else {
                return
            }
        } else {
            return
        }

        movePieces(direction, at: location)
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            movePieces(at: point)
        }
    }
}
#endif

#if os(OSX)
// Keybaord-based event handling
extension GameScene {
    override func keyDown(with event: NSEvent) {

    }

    override func keyUp(with event: NSEvent) {
        if let direction = Direction(rawValue: event.keyCode) {
            movePieces(direction)
        }
    }
}
#endif

