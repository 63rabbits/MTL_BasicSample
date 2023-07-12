import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {

    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture!

    @IBOutlet weak var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMetal()

        loadTexture()

        mtkView.enableSetNeedsDisplay = true

        // call draw()
        mtkView.setNeedsDisplay()
    }

    private func setupMetal() {
        commandQueue = device.makeCommandQueue()

        mtkView.device = device
        mtkView.delegate = self
        mtkView.framebufferOnly = false
    }

    private func loadTexture() {
        let textureLoader = MTKTextureLoader(device: device)
        texture = try! textureLoader.newTexture(
            name: "kerokero",
            scaleFactor: view.contentScaleFactor,
            bundle: nil)

        mtkView.colorPixelFormat = texture.pixelFormat
    }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // nop
    }

    func draw(in view: MTKView) {
        let drawable = view.currentDrawable!

        let commandBuffer = commandQueue.makeCommandBuffer()!

        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!

        let w = min(texture.width, drawable.texture.width)
        let h = min(texture.height, drawable.texture.height)
        blitEncoder.copy(
                            from: texture,         // source
                            sourceSlice: 0,
                            sourceLevel: 0,
                            sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                            sourceSize: MTLSizeMake(w, h, texture.depth),

                            to: drawable.texture,  // destination
                            destinationSlice: 0,
                            destinationLevel: 0,
                            destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0)
                        )

        blitEncoder.endEncoding()

        commandBuffer.present(drawable)

        commandBuffer.commit()

        commandBuffer.waitUntilCompleted()
    }
}

