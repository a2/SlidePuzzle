//
//  Array+Shuffle.swift
//  Slider Puzzle
//
//  Created by Alexsander Akers on 10/27/16.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import Foundation

extension Array {
    func shuffled() -> [Element] {
        var copy = self
        copy.shuffledInPlace()
        return copy
    }

    mutating func shuffledInPlace() {
        guard count > 1 else {
            return
        }

        for i in indices {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}
