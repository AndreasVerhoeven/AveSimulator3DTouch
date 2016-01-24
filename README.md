# 3D Touch Support for the Simulator
3D Touch Peek/Pop support for the Simulator for debugging purposes.

![3dtouchsimulator](https://cloud.githubusercontent.com/assets/168214/12538997/aaee2040-c2e8-11e5-8d51-1d0b716f5d71.gif)

# How To use
1. Add `Ave3DTouchSimulatorSupport.m` to your project
2. Build to run in the Simulator
3. While in the Simulator, tap & hold on a view registered for 3D Touch previewing
4. Hold down the COMMAND key while still holding the touch as well, until the "peek" preview is shown
4. When the peek preview is shown, hold down the CONTROL key as well to apply extra force to pop the preview

Summarizing:
 - COMMAND = increase force being applied, until the "peek" treshold
 - CONTROL = apply extra force, until the "pop" treshold
 - SHIFT = slow down the increase

# How does it work? 
By swizzling private UIKit methods and doing runtime trickery. In short, `-[UITouch _unclampedForce]` is overriden to use a simulated force value, controlled by holding the COMMAND/CONTROL/SHIFT keys while touching. Additional trickery is applied to make UIKit recognize the force changes by submitting fake touches and recognizing key presses.

# But, wouldn't Apple reject that for the App Store?
Yes, that's why this code will only be compiled when building for the simulator using an `#if TARGET_IPHONE_SIMULATOR`. If you are building for devices or distribution, `Ave3DTouchSimulatorSupport` is essentially an empty file. 

# License
 The MIT License (MIT)
 
 Copyright (c) 2015 Andreas Verhoeven (ave@aveapps.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
