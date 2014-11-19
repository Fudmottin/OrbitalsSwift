//
//  main.swift

import Foundation

func mapSetValueToByte (d: Double) -> Byte {
    if d.isNaN || d.isInfinite { return 0 }
    let v = 128.0 * d
    if v < 0.0 { return 0 }
    if v > 255.0 { return 255 }
    return Byte(v)
}

func mapOutsideValueToByte (d: Double) -> Byte {
    return Byte(min(log(d) * 255.0 / log(2_048.0), 255))
}

func main() {
    let width = 1280
    let height = 720
    let centerX = 0.5 // 0.74552972800463340
    let centerY = 0.0 // 0.08245763776447299
    let iterations = 2_048
    let zoom = 1.35

    var fractalData = Mandelbrot(width: width, height: height, zoom: zoom, centerX: centerX, centerY: centerY, iterations: iterations)
    var image = Bitmap(width: width, height: height)

    fractalData.computeSet()

    var imageData = [Byte](count: width * height * 4, repeatedValue: 255)
    var index = 0
    for scanLine in fractalData.scanLines {
        for value in scanLine {
            if value < 2.0 {
                imageData[index++] = 0x2f
                imageData[index++] = 0x2f
                imageData[index++] = mapSetValueToByte(value)
                index++
            } else {
                imageData[index++] = mapOutsideValueToByte(value)
                imageData[index++] = 0xef
                imageData[index++] = 0xef
                index++
            }
        }
    }

    println("Creating Image")
    image.setColorData(imageData)
    image.saveImage("/Users/david/Desktop/testImage.png")

    println("Done!")
    exit(0)
}

threads.runOnMainThread(main)
threads.run()
