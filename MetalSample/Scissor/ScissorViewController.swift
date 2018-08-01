//
//  ScissorViewController.swift
//  MetalSample
//
//  Created by Ryo Izumi on 2018/08/01.
//  Copyright © 2018年 izm. All rights reserved.
//

import UIKit

class ScissorViewController: UIViewController {
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    
    @IBOutlet weak var mtlView: UIView!
    
    let vertexData:[Float] = [
        0.0,  1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]
    
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    
    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        mtlView.layer.addSublayer(metalLayer)
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "scissor_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "scissor_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ScissorViewController.loop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metalLayer.frame = CGRect(x: 0.0,y: 0.0,width: mtlView.frame.width,height: mtlView.frame.height)
    }
    
    func render(){
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDesctiptor = MTLRenderPassDescriptor()
        renderPassDesctiptor.colorAttachments[0].texture = drawable.texture
        renderPassDesctiptor.colorAttachments[0].loadAction = .clear
        renderPassDesctiptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDesctiptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        let rect = MTLScissorRect(x: 0, y: 0, width: Int(mtlView.frame.size.width/2), height: Int(mtlView.frame.size.height))
        renderEncoder?.setScissorRect(rect)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    @objc func loop(){
        autoreleasepool {
            self.render()
        }
    }
}
