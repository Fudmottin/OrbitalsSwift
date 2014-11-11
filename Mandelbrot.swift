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
    func computeLine(complex: DoubleSplitComplexVector, iterations: Int) -> DoubleSplitComplexVector {
        let len = vDSP_Length(complex.real.count)
        var c_vector = complex
        var c = DSPDoubleSplitComplex(realp: &c_vector.real, imagp: &c_vector.imag)
        var z_vector = complex
        var z = DSPDoubleSplitComplex(realp: &z_vector.real, imagp: &z_vector.imag)
        var r_vector = complex
        var r = DSPDoubleSplitComplex(realp: &r_vector.real, imagp: &r_vector.imag)

        for i in 0 ..< iterations {
            vDSP_zvmulD (&z, 1, &z, 1, &r, 1,len, 1)
            vDSP_zvaddD(&r, 1, &c, 1, &z, 1, len)
        }

        var result = DoubleSplitComplexVector()
        result.real = z_vector.real
        result.imag = z_vector.imag
        
        return result
    }

    func distanceFromOrigin(complex: DoubleSplitComplexVector) -> [Double] {
        var d = [Double](count: complex.real.count, repeatedValue: 0.0)
        vDSP_vdistD(complex.real, 1, complex.imag, 1, &d, 1, vDSP_Length(complex.real.count))
        return d
    }

    func computeSet() {
        for line in 0 ..< pixelHeight {
            threads.runOnComputationThread() {
                var splitComplexVector = DoubleSplitComplexVector()
                var imagVec = [Double](count: self.pixelWidth, repeatedValue: self.iArray[line])
                splitComplexVector.real = self.rArray
                splitComplexVector.imag = imagVec
                self.scanLines[line] = self.distanceFromOrigin(self.computeLine(splitComplexVector, iterations: self.iterations))
            }
        }
        threads.waitAll()
    }
    
}

