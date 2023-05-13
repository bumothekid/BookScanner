//
//  SignInController.swift
//  BookScanner
//
//  Created by David Riegel on 10.05.23.
//

import UIKit
import FirebaseAuth

class SignInController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    lazy var logoImageView: UIImageView = {
        var iv = UIImageView(image: UIImage(named: "transparentIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var signInLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .label
        lb.font = UIFont.systemFont(ofSize: 26, weight: .black)
        lb.textAlignment = .center
        lb.text = "Welcome back, sign in"
        return lb
    }()
    
    lazy var emailTextField: UITextField = {
        var tf = UITextField()
        tf.textColor = .label
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = .secondarySystemBackground
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = false
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.delegate = self
        tf.addTarget(self, action: #selector(checkTextFieldInputs), for: .editingChanged)
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        var tf = UITextField()
        tf.textColor = .label
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = .secondarySystemBackground
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .continue
        tf.delegate = self
        tf.addTarget(self, action: #selector(checkTextFieldInputs), for: .editingChanged)
        return tf
    }()
    
    lazy var signInButton: UIButton = {
        var bt = UIButton()
        bt.alpha = 0.2
        bt.isEnabled = false
        bt.backgroundColor = .label
        bt.layer.cornerRadius = 5
        bt.setTitle("Sign In", for: .normal)
        bt.setTitleColor(UIColor.systemBackground, for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        bt.titleLabel?.textAlignment = .center
        bt.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return bt
    }()
    
    lazy var signUpTextButton: UIButton = {
        var bt = UIButton()
        var title = NSMutableAttributedString(string: "Don't have an Account? ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.label, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        title.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.foregroundColor : UIColor.link, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
        bt.setAttributedTitle(title, for: .normal)
        bt.titleLabel?.textAlignment = .center
        bt.addTarget(self, action: #selector(pushSignUp), for: .touchUpInside)
        return bt
    }()
    
    @objc func handleSignIn() {
        Task {
            await signInUser(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }
    
    @objc func pushSignUp() {
        DispatchQueue.main.async {
            let vc = SignUpController()
            vc.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc
    func checkTextFieldInputs() {
        if !(emailTextField.text?.count ?? 0 > 0) || !(passwordTextField.text?.count ?? 0 > 0) {
            signInButton.alpha = 0.2
            signInButton.isEnabled = false
            return
        }
        
        signInButton.alpha = 1
        signInButton.isEnabled = true
    }
    
    func signInUser(email: String, password: String) async {
        do {
            try await DatabaseHandler.shared.loginUser(email: email, password: password)
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        catch {
            DispatchQueue.main.async { [weak self] in
                var errorString = ""
                
                switch AuthErrorCode.Code(rawValue: error._code) {
                case .invalidEmail:
                    errorString = "The email needs to be in a valid format example@email.com"
                case .userNotFound, .wrongPassword:
                    errorString = "The email or password is wrong"
                default:
                    errorString = "Unknown Error"
                    print("Unknown Error:")
                    print(error)
                }
                
                let alert = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 150, paddingLeft: 40, paddingRight: -40)
        
        view.addSubview(signInLabel)
        signInLabel.anchor(top: logoImageView.bottomAnchor, left: logoImageView.leftAnchor, right: logoImageView.rightAnchor)
        
        view.addSubview(emailTextField)
        emailTextField.anchor(top: signInLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: -20, height: 45)
        
        view.addSubview(passwordTextField)
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(signInButton)
        signInButton.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, right: passwordTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(signUpTextButton)
        signUpTextButton.anchor(top: signInButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: -20)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

extension SignInController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            
            view.hideKeyboard()
            if signInButton.isEnabled {
                Task {
                    print("Sign In")
                }
            }
        }
        
        return true
    }
}
