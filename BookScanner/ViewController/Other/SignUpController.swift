//
//  SignUpController.swift
//  BookScanner
//
//  Created by David Riegel on 10.05.23.
//

import UIKit
import FirebaseAuth

class SignUpController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    lazy var logoImageView: UIImageView = {
        var iv = UIImageView(image: UIImage(named: "transparentIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var signUpLabel: UILabel = {
        var lb = UILabel()
        lb.textColor = .label
        lb.font = UIFont.systemFont(ofSize: 26, weight: .black)
        lb.textAlignment = .center
        lb.text = "Welcome, sign up"
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
    
    lazy var displayNameTextField: UITextField = {
        var tf = UITextField()
        tf.textColor = .label
        tf.attributedPlaceholder = NSAttributedString(string: "Display name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
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
    
    lazy var usernameTextField: UITextField = {
        var tf = UITextField()
        tf.textColor = .label
        tf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
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
    
    lazy var passwordConfirmTextField: UITextField = {
        var tf = UITextField()
        tf.textColor = .label
        tf.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
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
    
    lazy var signUpButton: UIButton = {
        var bt = UIButton()
        bt.alpha = 0.2
        bt.isEnabled = false
        bt.backgroundColor = .label
        bt.layer.cornerRadius = 5
        bt.setTitle("Sign Up", for: .normal)
        bt.setTitleColor(UIColor.systemBackground, for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        bt.titleLabel?.textAlignment = .center
        bt.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return bt
    }()
    
    lazy var signInTextButton: UIButton = {
        var bt = UIButton()
        var title = NSMutableAttributedString(string: "Already have an Account? ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.label, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        title.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.foregroundColor : UIColor.link, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
        bt.setAttributedTitle(title, for: .normal)
        bt.titleLabel?.textAlignment = .center
        bt.addTarget(self, action: #selector(pushSignIn), for: .touchUpInside)
        return bt
    }()
    
    @objc func handleSignUp() {
        Task {
            guard passwordTextField.text?.count ?? 0 >= 8 else {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: nil, message: "The password length needs to be at least 8 characters long", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(alert, animated: true)
                }
                
                return
            }
            
            let isAvailable = try await DatabaseHandler.shared.checkUsernameAvailability(usernameTextField.text ?? "")
            
            guard isAvailable else {
                let alert = UIAlertController(title: nil, message: "This username is already in use", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            await signUpUser(email: emailTextField.text ?? "", displayname: displayNameTextField.text ?? "", username: usernameTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }
    
    @objc func pushSignIn() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    func checkTextFieldInputs(_ textField: UITextField) {
        if textField == usernameTextField {
            usernameTextField.text = usernameTextField.text?.lowercased() ?? ""
        }
        
        if !(emailTextField.text?.count ?? 0 > 0) || !(displayNameTextField.text?.count ?? 0 > 0) || !(usernameTextField.text?.count ?? 0 > 0) || !(passwordTextField.text?.count ?? 0 > 0) || !(passwordConfirmTextField.text?.count ?? 0 > 0) || !(passwordTextField.text ?? "" == passwordConfirmTextField.text ?? "") {
            signUpButton.alpha = 0.2
            signUpButton.isEnabled = false
            return
        }
        
        signUpButton.alpha = 1
        signUpButton.isEnabled = true
    }
    
    func signUpUser(email: String, displayname: String, username: String, password: String) async {
        do {
            try await DatabaseHandler.shared.registerUser(email: email, displayname: displayname, username: username, password: password)
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        catch {
            var errorString = ""
            
            switch AuthErrorCode.Code(rawValue: error._code) {
            case .invalidEmail:
                errorString = "The email needs to be in a valid format example@email.com"
            case .emailAlreadyInUse:
                errorString = "The email is already in use"
            default:
                errorString = "Unknown Error"
                print("Unknown Error:")
                print(error)
            }
            
            let alert = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true, completion: nil)
        }
    }

    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        
        navigationItem.largeTitleDisplayMode = .never
            
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 150, paddingLeft: 40, paddingRight: -40)
        
        view.addSubview(signUpLabel)
        signUpLabel.anchor(top: logoImageView.bottomAnchor, left: logoImageView.leftAnchor, right: logoImageView.rightAnchor)
        
        view.addSubview(emailTextField)
        emailTextField.anchor(top: signUpLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: -20, height: 45)
        
        view.addSubview(displayNameTextField)
        displayNameTextField.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: emailTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(usernameTextField)
        usernameTextField.anchor(top: displayNameTextField.bottomAnchor, left: displayNameTextField.leftAnchor, right: displayNameTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(passwordTextField)
        passwordTextField.anchor(top: usernameTextField.bottomAnchor, left: usernameTextField.leftAnchor, right: usernameTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(passwordConfirmTextField)
        passwordConfirmTextField.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, right: passwordTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: passwordConfirmTextField.bottomAnchor, left: passwordConfirmTextField.leftAnchor, right: passwordConfirmTextField.rightAnchor, paddingTop: 20, height: 45)
        
        view.addSubview(signInTextButton)
        signInTextButton.anchor(top: signUpButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: -20)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

extension SignUpController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            displayNameTextField.becomeFirstResponder()
        }
        else if textField == displayNameTextField {
            usernameTextField.becomeFirstResponder()
        }
        else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            passwordConfirmTextField.becomeFirstResponder()
        }
        else {
            
            view.hideKeyboard()
            if signUpButton.isEnabled {
                Task {
                    handleSignUp()
                }
            }
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard (string.rangeOfCharacter(from: CharacterSet.newlines) == nil) else {
            return false
        }
        
        if textField != displayNameTextField {
            guard (string.rangeOfCharacter(from: CharacterSet.whitespaces) == nil) else {
                return false
            }
        }
        switch textField {
        case displayNameTextField:
            guard !((displayNameTextField.text?.count ?? 0) >= 30) else {
                return false
            }
            
            return true
        case usernameTextField:
            guard !((usernameTextField.text?.count ?? 0) >= 18) else {
                return false
            }
            
            return true
        default:
            return true
        }
    }
}

