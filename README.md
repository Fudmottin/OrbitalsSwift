OrbitalsSwift
================

Simple Swift code for exploring the interior of the Mandelbrot Set.

This is purely experimental code. It’s based on a small C program I wrote in June 2013. This code accesses the vDSP functions of the Accelerate Framework as well as using GCD. It’s written as a command line program to avoid the distraction of having an actual user interface.

So far, all my runs have been from inside Xcode 6.1. It can peg all the cores with large numbers of iterations. As it is, it only needs a couple thousand for a sharp image. In that case, with zoom set to 1.5, almost all the time is spent transferring the fractal data to a buffer for making a CGImage to be written out to disk.


Use this code how you like.
Attempt no copyrights.
Use it together. Use it in peace.

Create a new command line OS X app in Swift to use the files and see how it runs.
