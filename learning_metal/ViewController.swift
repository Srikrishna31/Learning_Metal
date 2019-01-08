//
//  ViewController.swift
//  learning_metal
//
//  Created by Krishna Addepalli on 07/01/19.
//  Copyright © 2019 Oracle. All rights reserved.
//

import Metal
import UIKit
import QuartzCore

class ViewController: UIViewController {

    var device:MTLDevice! = nil
    var defaultLibrary : MTLLibrary! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var metalLayer = CAMetalLayer()
    var commandQueue: MTLCommandQueue! = nil
    var vertexBuffer: MTLBuffer! = nil
    var timer: CADisplayLink! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        device = MTLCreateSystemDefaultDevice()

        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)

        let vertexData:[Float] = [
            0.0, 0.5, 0.0,
            -0.5, -0.5, 0.0,
            0.5, -0.5, 0.0]

        let dataSize = vertexData.count *
            MemoryLayout.size(ofValue: vertexData[0])

        vertexBuffer = device.makeBuffer(bytes: vertexData,
                                         length: dataSize,
                                         options: .storageModeShared)

        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }

        commandQueue = device.makeCommandQueue()

        timer = CADisplayLink(target: self, selector:
            #selector(ViewController.gameLoop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }


    func render()
    {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let drawable = metalLayer.nextDrawable() else { return }
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 221.0/255.0, green: 160.0/255.0,
                          blue: 221.0/255.0, alpha: 1.0)

        let commandBuffer = commandQueue.makeCommandBuffer()

        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer,  offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 3)
        renderEncoder?.endEncoding()

        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    /*
     @objc tells Swift to automatically generate Objective-C thunk.
     https://www.hackingwithswift.com/example-code/language/how-to-fix-argument-of-selector-refers-to-instance-method-that-is-not-exposed-to-objective-c
    */
    @objc func gameLoop() {
        autoreleasepool {
            render()
        }
    }
}

