//
//  CameraView.swift
//  Voyage
//
//  Created by Graciella Adriani Seciawanto on 26/05/24.
//

import SwiftUI
import AVFoundation


class BridgingCoordinator: ObservableObject {
    var vc: CameraViewController!
}

struct CameraView: UIViewControllerRepresentable {
    var bridgingCoordinator: BridgingCoordinator
    let onCapture: (UIImage?) -> Void
    
    func makeCoordinator() -> CameraCoordinator {
        return CameraCoordinator(self, onCapture: onCapture)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraController = CameraViewController()
        cameraController.bridgingCoordinator = bridgingCoordinator
        cameraController.delegate = context.coordinator
        return cameraController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    class CameraCoordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraView
        let onCapture: (UIImage?) -> Void

        
        init(_ view: CameraView, onCapture: @escaping (UIImage?) -> Void) {
            self.parent = view
            self.onCapture = onCapture
        }
        
        func imageCaptured(_ image: UIImage) {
            onCapture(image)
        }
    }
    
    protocol CameraViewControllerDelegate: AnyObject {
        func imageCaptured(_ image: UIImage)
    }
    
    class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
        var captureSession: AVCaptureSession!
        var photoOutput: AVCapturePhotoOutput!
        weak var delegate: CameraViewControllerDelegate?
        var bridgingCoordinator: BridgingCoordinator!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupCamera()
        }
        
        func setupCamera() {
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            
            guard let camera = AVCaptureDevice.default(for: .video) else { return }
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                print("Error setting up camera input: \(error.localizedDescription)")
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                        self?.capturePhotoContinuously()
                    }
        }
        
        func capturePhotoContinuously() {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                delegate?.imageCaptured(UIImage())
                return
            }
            delegate?.imageCaptured(image)
            
            // Capture the next photo
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                        self?.capturePhotoContinuously()
                    }
        }
    }
}
