//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let aView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 620))
aView.backgroundColor = .blue

let gView = GliderView(resource: GliderResource(type: .local("Cloud")))
gView.frame = CGRect(x: 20, y: 20, width: 200, height: 100)
gView.contentMode = .scaleAspectFit
gView.loops = true
gView.startAnimating()
aView.addSubview(gView)

let gView2 = GliderView(resource: GliderResource(type: .local("Cloud")))
gView2.frame = CGRect(x: 20, y: 140, width: 200, height: 100)
gView2.contentMode = .scaleAspectFill
gView2.loops = true
gView2.startAnimating()
aView.addSubview(gView2)

let gView3 = GliderView(resource: GliderResource(type: .local("Cloud")))
gView3.frame = CGRect(x: 20, y: 260, width: 200, height: 100)
gView3.contentMode = .scaleToFill
gView3.loops = true
gView3.startAnimating()
aView.addSubview(gView3)

let gView4 = GliderView(resource: GliderResource(type: .local("Cloud")))
gView4.frame = CGRect(x: 20, y: 380, width: 200, height: 100)
gView4.contentMode = .center
gView4.loops = true
gView4.startAnimating()
aView.addSubview(gView4)

PlaygroundPage.current.liveView = aView
