//
//  ColorPlane.swift

import Foundation

final class ColorPlane {
    var width: Int
    var height: Int
    var data: [Int]

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.data = [Int](count: width * height, repeatedValue: 0)
    }

    func increment(x: Int, y: Int) {
        data[x * y + x]++
    }

    func findMax() -> Int {
        var m = 0
        for num in data {
            m = max(num, m)
        }
        return m
    }

    func normalized(by: Double) -> ColorPlane {
        var cp = ColorPlane(width: width, height: height)
        cp.data = data.map() {
            return Int(Double($0) / by)
        }
        return cp
    }
}