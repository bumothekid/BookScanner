//
//  ScannerViewController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            guard await askForCameraPermissions() else { return }
            configureViewComponents()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func readBarcode(_ data: String) {
        Task {
            do {
                let book = try await APICaller().getBookByISBN(data)
                
                guard try await BookHandler().getBookByISBN(data) == nil else {
                    let alertController = UIAlertController(title: book.title, message: "\(book.industryIdentifiers[1].identifier) is already in your book shelf.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        if self.captureSession.isRunning == false {
                            self.captureSession.startRunning()
                        }
                    }))
                    
                    present(alertController, animated: true)
                    return
                }
                
                let alertController = UIAlertController(title: book.title, message: "Do you want to add \(book.industryIdentifiers[1].identifier) to your book shelf?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.saveBook(book)
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    if self.captureSession.isRunning == false {
                        self.captureSession.startRunning()
                    }
                }))
                
                present(alertController, animated: true)
            }
            catch let e {
                print("An error occured.")
                print(e)
            }
        }
    }
    
    func askForCameraPermissions() async -> Bool {
        var cameraPermissions = AVCaptureDevice.authorizationStatus(for: .video)
        
        if cameraPermissions == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    print("Camera video permissions declined.")
                }
            }
            
            cameraPermissions = AVCaptureDevice.authorizationStatus(for: .video)
        }
        
        return cameraPermissions == AVAuthorizationStatus.authorized
    }
    
    func notSupported() {
        let alertController = UIAlertController(title: "", message: "Scanning is not supported on your device.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alertController, animated: true)
        captureSession = nil
    }
    
    func saveBook(_ book: Book) {
        Task {
            try await BookHandler().saveBook(book)
        }
    }
    
    func configureViewComponents() {
        view.backgroundColor = .systemBackground
        title = "Scanner"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        }
        catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        else {
            notSupported()
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        }
        else {
            notSupported()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metaDataObject = metadataObjects.first {
            guard let readableObject = metaDataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            readBarcode(stringValue)
        }
    }
}
