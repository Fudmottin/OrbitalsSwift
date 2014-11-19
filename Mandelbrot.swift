//
//  Mandelbrot.swift

import Foundation
import Accelerate

struct DoubleSplitComplexVector {
    var real: [Double]
    var imag: [Double]

    init() {
        self.real = []
        self.imag = []
    }
    
    init(length: Int) {
        self.real = [Double](count: length, repeatedValue: 0.0)
        self.imag = [Double](count: length, repeatedValue: 0.0)
    }
}

final class Mandelbrot {
    let iterations: Int
    let pixelWidth: Int
    let pixelHeight: Int
    let mapWidth: Double
    let mapHeight: Double
    let centerReal: Double
    let centerImaginary: Double
    let rArray: [Double]
    let iArray: [Double]
    var scanLines = [[Double]()]

    init(width: Int, height: Int, zoom: Double, centerX: Double, centerY: Double, iterations: Int) {
        pixelWidth = width
        pixelHeight = height
        self.iterations = iterations
        mapWidth = (3.0 / zoom) * (Double(pixelWidth) / Double(pixelHeight))
        mapHeight = 3.0 / zoom
        centerReal = Double(mapWidth) / 2.0 + centerX
        centerImaginary = Double(mapHeight) / 2.0 + centerY

        rArray = [Double](count: pixelWidth, repeatedValue: 0.0)
        iArray = [Double](count: pixelHeight, repeatedValue: 0.0)
        scanLines = [[Double]](count: height, repeatedValue: [Double]())

        for i in 0 ..< pixelWidth {
            rArray[i] = Double(i) * mapWidth / Double(pixelWidth) - centerReal
        }
        for i in 0 ..< pixelHeight {
            iArray[i] = Double(i) * mapHeight / Double(pixelHeight) - centerImaginary
        }
    }

    // Use vector processing to compute Mandelbrot Set
    func computeLine(complex: DoubleSplitComplexVector, iterations: Int) -> [Double] {
        let len = vDSP_Length(complex.real.count)
        var c_vector = complex
        var c = DSPDoubleSplitComplex(realp: &c_vector.real, imagp: &c_vector.imag)
        var z_vector = complex
        var z = DSPDoubleSplitComplex(realp: &z_vector.real, imagp: &z_vector.imag)
        var r_vector = complex
        var r = DSPDoubleSplitComplex(realp: &r_vector.real, imagp: &r_vector.imag)
        var d = [Double](count: complex.real.count, repeatedValue: 0.0)
        var result = d

        // this is a work around for a bug in the compiler not finding methods on d[j]
        func doAssign(d: Double, r: Double) -> Bool {
            if r == 0.0 && d.isFinite && d > 2.0 {
                return true
            }
            return false
        }

        for i in 1 ... iterations {
            // the heavy bit
            for j in 0 ..< Int(len) {
                if doAssign(d[j], result[j]) {
                    result[j] = Double(i)
                }
            }

            vDSP_zvmulD (&z, 1, &z, 1, &r, 1,len, 1)
            vDSP_zvaddD(&r, 1, &c, 1, &z, 1, len)
            vDSP_vdistD(z.realp, 1, z.imagp, 1, &d, 1, len)
        }

        // this allows us to color the inside of the set also
        for j in 0 ..< Int(len) {
            if result[j] == 0.0 && d[j] < 2.0 {
                result[j] = d[j]
            }
        }

        return result
    }

    func computeSet() {
        for line in 0 ..< pixelHeight {
            threads.runOnComputationThread() {
                var splitComplexVector = DoubleSplitComplexVector()
                var imagVec = [Double](count: self.pixelWidth, repeatedValue: self.iArray[line])
                splitComplexVector.real = self.rArray
                splitComplexVector.imag = imagVec
                self.scanLines[line] = self.computeLine(splitComplexVector, iterations: self.iterations)
                println("Line: \(line)")
            }
        }
        threads.waitAll()
        println("Done!")
    }
    
}

