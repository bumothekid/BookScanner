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
    let userProfile: User!

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
    
    override func viewDidLayoutSubviews() {
        Task {
            await prepareCaptureSessionAndPreviewLayer()
            
            captureSession.startRunning()
        }
    }
    
    required init(profile: User) {
        userProfile = profile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var scanView: UIView = {
        let view = UIView(frame: CGRect(x: view.frame.width/2 - 100, y: view.frame.height/2 - 150, width: 200, height: 100))
        view.backgroundColor = .blue
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    lazy var darkenView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.clipsToBounds = true
        return view
    }()
    
    lazy var cutoutLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = darkenView.frame
        shapeLayer.fillRule = .evenOdd
            
        let path = UIBezierPath(rect: darkenView.frame)
        path.append(UIBezierPath(roundedRect: scanView.frame, cornerRadius: 10))
        shapeLayer.path = path.cgPath
        
        return shapeLayer
    }()
    
    lazy var infoTextBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackgroundColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var infoLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .label
        lb.font = .systemFont(ofSize: 14, weight: .bold)
        lb.text = "Please scan a book barcode."
        return lb
    }()
    
    lazy var infoImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .label
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "info.bubble.fill")
        return iv
    }()
    
    func readBarcode(_ data: String) {
        Task {
            do {
                guard data.hasPrefix("978") else {
                    let alertController = UIAlertController(title: nil, message: "Please scan only books.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        if !self.captureSession.isRunning {
                            self.captureSession.startRunning()
                        }
                    }))
                    
                    present(alertController, animated: true)
                    return
                }
                
                let book = try await APICaller.shared.getBookByISBN(data)
                
                guard try await BookHandler().getBookByISBN(data) == nil else {
                    let alertController = UIAlertController(title: book.title, message: "\(book.isbn) is already in your book shelf.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        if !self.captureSession.isRunning {
                            self.captureSession.startRunning()
                        }
                    }))
                    
                    present(alertController, animated: true)
                    return
                }
                
                let alertController = UIAlertController(title: book.title, message: "Do you want to add \(book.isbn) to your book shelf?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.saveBook(book)
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    if !self.captureSession.isRunning {
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
            try await BookHandler().saveBook(book: book, user: userProfile)
        }
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "Scanner"
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = .backgroundColor
        
        view.addSubview(previewView)
        previewView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
        
        previewView.addSubview(darkenView)
        darkenView.layer.mask = cutoutLayer
        
        previewView.addSubview(infoTextBackground)
        infoTextBackground.anchor(left: previewView.leftAnchor, bottom: previewView.bottomAnchor, right: previewView.rightAnchor, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, height: 50)
//        infoTextBackground.rightAnchor.constraint(lessThanOrEqualTo: previewView.rightAnchor, constant: -20).isActive = true
        
        infoTextBackground.addSubview(infoImageView)
        infoImageView.anchor(left: infoTextBackground.leftAnchor, paddingLeft: 15, width: 25, height: 25)
        infoImageView.centerYAnchor.constraint(equalTo: infoTextBackground.centerYAnchor).isActive = true
        
        infoTextBackground.addSubview(infoLabel)
        infoLabel.anchor(left: infoImageView.rightAnchor, right: previewView.rightAnchor, paddingLeft: 5, paddingRight: -15)
        infoLabel.centerYAnchor.constraint(equalTo: infoTextBackground.centerYAnchor).isActive = true
    }
    
    
    func prepareCaptureSessionAndPreviewLayer() async {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        
        guard captureSession.canAddInput(videoInput) else {
            notSupported()
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        guard captureSession.canAddOutput(metaDataOutput) else {
            notSupported()
            return
        }
        
        captureSession.addOutput(metaDataOutput)
            
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = previewView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewView.layer.insertSublayer(previewLayer, at: 0)
        let scanArea = previewLayer.metadataOutputRectConverted(fromLayerRect: scanView.frame)
        
        metaDataOutput.rectOfInterest = scanArea
        metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metaDataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        guard metadataObjects.count < 2 else { return }
        
        if let metaDataObject = metadataObjects.first {
            guard let readableObject = metaDataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            readBarcode(stringValue)
        }
    }
}
