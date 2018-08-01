//
//  FrameBufferObjectViewController.swift
//  MetalSample
//
//  Created by izumi on 2018/07/31.
//  Copyright © 2018 izm. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class FrameBufferObjectViewController: UIViewController {
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!

    @IBOutlet weak var mtlView: UIView!
    
    let vertexData:[Float] = [
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0,
        -1.0,  1.0, 0.0,
        1.0,  1.0, 0.0
    ]
    
    let vertexDataFbo:[Float] = [
        0.0,  1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    
    let texCoords:[Float] = [
        0.0,0.0,
        1.0,0.0,
        0.0,1.0,
        1.0,1.0
    ]
    
    var vertexBuffer: MTLBuffer!
    var vertexBufferFbo: MTLBuffer!
    var texCoordsBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var pipelineStateFbo: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var texture:MTLTexture!
    var textureFbo: MTLTexture!

    var timer: CADisplayLink!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        makeBuffers()
        
        makeRenderPipelineStates()

        createTextures()
        
        timer = CADisplayLink(target: self, selector: #selector(UniformViewController.loop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metalLayer.frame = CGRect(x: 0.0, y: 0.0, width: mtlView.frame.width, height: mtlView.frame.height)
    }
    
    private func setup(){
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        mtlView.layer.addSublayer(metalLayer)
        
        commandQueue = device.makeCommandQueue()
    }
    
    private func makeBuffers(){
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let dataSizeFbo = vertexDataFbo.count * MemoryLayout.size(ofValue: vertexDataFbo[0])
        vertexBufferFbo = device.makeBuffer(bytes: vertexDataFbo, length: dataSizeFbo, options: [])
        
        let dataSizeTexcoords = texCoords.count * MemoryLayout.size(ofValue: texCoords[0])
        texCoordsBuffer = device.makeBuffer(bytes: texCoords, length: dataSizeTexcoords, options: [])
    }
    
    private func makeRenderPipelineStates(){
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "framebufferobject_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "framebufferobject_vertex")
        
        let fragmentProgramFbo = defaultLibrary.makeFunction(name: "framebufferobject_fragment_fbo")
        let vertexProgramFbo = defaultLibrary.makeFunction(name: "framebufferobject_vertex_fbo")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        let pipelineStateDescriptorFbo = MTLRenderPipelineDescriptor()
        pipelineStateDescriptorFbo.vertexFunction = vertexProgramFbo
        pipelineStateDescriptorFbo.fragmentFunction = fragmentProgramFbo
        pipelineStateDescriptorFbo.sampleCount = 4
        pipelineStateDescriptorFbo.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineStateFbo = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptorFbo)
    }
    
    private func createTextures(){
        let mtlTextureDescriptor = MTLTextureDescriptor()
        mtlTextureDescriptor.pixelFormat = .bgra8Unorm
        mtlTextureDescriptor.width = 256
        mtlTextureDescriptor.height = 256
        mtlTextureDescriptor.usage = .shaderRead
        texture = device.makeTexture(descriptor: mtlTextureDescriptor)

        let mtlTextureDescriptorFbo = MTLTextureDescriptor()
        mtlTextureDescriptorFbo.pixelFormat = .bgra8Unorm
        mtlTextureDescriptorFbo.width = 256
        mtlTextureDescriptorFbo.height = 256
        mtlTextureDescriptorFbo.textureType = .type2DMultisample
        mtlTextureDescriptorFbo.sampleCount = 4
        mtlTextureDescriptorFbo.usage = .renderTarget
        textureFbo = device.makeTexture(descriptor: mtlTextureDescriptorFbo)
    }
    
    func renderFbo(){
        let renderPassDesctiptor = MTLRenderPassDescriptor()
        renderPassDesctiptor.colorAttachments[0].texture = textureFbo
        renderPassDesctiptor.colorAttachments[0].resolveTexture = texture
        renderPassDesctiptor.colorAttachments[0].loadAction = .clear
        renderPassDesctiptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDesctiptor.colorAttachments[0].storeAction = .storeAndMultisampleResolve
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDesctiptor)
        renderEncoder?.setRenderPipelineState(pipelineStateFbo)
        renderEncoder?.setVertexBuffer(vertexBufferFbo, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder?.endEncoding()
        
        commandBuffer?.commit()
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
        renderEncoder?.setVertexBuffer(texCoordsBuffer, offset: 0, index: 1)
        renderEncoder?.setFragmentTexture(texture, index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    @objc func loop(){
        autoreleasepool {
            self.renderFbo()
            self.render()
        }
    }
}
