# SampleApp

This is a small benchmark to demonstrate the performance benefits of
the optimizations described in our OOPSLA 2019 paper.  The benchmark
has a structure mimicking parts of the proprietary application described
in that paper, and gives an idea of how our optimizations work on
the proprietary app.

Overview
--------

The source code is at "Sources/SampleApp/main.swift".

 
Binary distribution
--------------------
The binaries SampleApp_unopt and SampleApp_opt can be run on a Mac OS to see at
least 12% performance difference [Mac OS 10.15 on 6-core MacBook Pro].

Build from Source with a Swift toolchain
----------------------------------------

The build process from sources uses Swift Package Manager and the dependencies
are specified in Package.swift.

Follow the instructions in zenodo website using the DOI 10.5281/zenodo.3366380
(https://zenodo.org/record/3366380#.XVH6LZNKii4)


Questions
---------

Email Raj Barik (rkbarik@gmail.com)

