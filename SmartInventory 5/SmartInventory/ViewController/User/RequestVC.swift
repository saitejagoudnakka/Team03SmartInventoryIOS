
import UIKit
import MobileCoreServices
import PDFKit
import FirebaseStorage

class RequestVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var addFileName: UILabel!
    @IBOutlet weak var warehouseIdTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var upcTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!

    var reportPath = ""
    var email = ""
    let imagePicker = UIImagePickerController()
    
    var docImageBool = false
    var selectedimage = UIImage()
    var docUrl = [URL]()
    var activityIndicator: UIActivityIndicatorView!
    var productData: RequestModel?
    var totalProduct = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        quantityTxt.delegate = self
        quantityTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.showProductData()
    }

    
    func showProductData(){
        self.productNameTxt.text = productData?.productname
        self.upcTxt.text = productData?.upcNumber
        self.warehouseIdTxt.text = productData?.warehouseID
        
        totalProduct = Int(productData?.quantity ?? "0") ?? 0

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            guard let text = textField.text, let enteredQuantity = Int(text) else {
                return
            }

            if enteredQuantity <= totalProduct {
                self.quantityTxt.text = "\(enteredQuantity)"
            } else {
                showAlerOnTop(message: "Exceed Quantity limit")
            }
        }
    
    @IBAction func uploadFileAction(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        
        let chooseImageAction = UIAlertAction(title: "Choose Image", style: .default) { [weak self] _ in
            self?.openImagePicker()
        }
        
        let chooseDocumentAction = UIAlertAction(title: "Choose Document", style: .default) { [weak self] _ in
            self?.openDocumentPicker()
        }
        
        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(chooseImageAction)
        actionSheet.addAction(chooseDocumentAction)
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func openImagePicker(){
        docImageBool = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openDocumentPicker(){
        docImageBool = true
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc", kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                let imageName = imageURL.lastPathComponent
                print("Image Name: \(imageName)")
                self.selectedimage = selectedImage
                self.addFileName.text = imageName
            }
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func validate() ->Bool {
        
        if(self.productNameTxt.text!.isEmpty) {
             showAlerOnTop(message: "Please enter Product name.")
            return false
        }
        if(self.upcTxt.text!.isEmpty) {
             showAlerOnTop(message: "Please enter UPC number")
            return false
        }
        if(self.quantityTxt.text!.isEmpty) {
            showAlerOnTop(message: "Please enter Quantity")
           return false
        }
        if !isValidInteger(self.quantityTxt.text ?? ""){
            showAlerOnTop(message: "Please enter valid Quantity")
           return false
        }
        
        if(self.warehouseIdTxt.text!.isEmpty) {
           showAlerOnTop(message: "Please enter warehouse id")
          return false
        }
        
        if(self.addFileName.text!.isEmpty) {
            showAlerOnTop(message: "Please add Shiping label")
            return false
        }
        
        return true
    }
    
    func isValidInteger(_ input: String) -> Bool {
        return Int(input) != nil
    }
    
    
    @IBAction func btnAddReport(_ sender: UIButton) {
        if validate(){
            
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            if docImageBool {
                self.uploadFileInToFirebase(urls: self.docUrl)
            }
            self.uploadImageToFirebase(image: selectedimage, imageName: self.addFileName.text ?? "")
        }
    }

}

extension RequestVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedPDFURL = urls.first {
            addFileName.text = selectedPDFURL.lastPathComponent
            self.docUrl = urls
        }
    }
    
    func savePDFToDocumentDirectory(pdfURL: URL) {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let destinationURL = documentDirectory.appendingPathComponent(pdfURL.lastPathComponent)
            try FileManager.default.copyItem(at: pdfURL, to: destinationURL)
            print("PDF saved to: \(destinationURL)")
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }
}

extension RequestVC{
    func uploadImageToFirebase(image: UIImage, imageName: String) {
        let storage = Storage.storage()
        
        let imageRef = storage.reference().child("Documents/\(email)/\(imageName)")
        
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    print("Image uploaded successfully")
                    imageRef.downloadURL { (url: URL?, error: Error?) in
                        if let error = error {
                            print("Error fetching download URL: \(error.localizedDescription)")
                        } else if let downloadURL = url {
                            let stringValue = downloadURL.absoluteString
                            self.uploadRequestToFirestore(fileUrl: stringValue)
                        }
                    }
                }
            }
        }
    }


    
    func uploadFileInToFirebase(urls:[URL]) {
        for url in urls {
            let fileType = url.pathExtension.lowercased()
            
            let storage = Storage.storage()
            
            let storageRef = storage.reference().child("Documents/\(email)/\(fileType)")
            
            storageRef.putFile(from: url, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading file: \(error.localizedDescription)")
                } else {
                    print("File uploaded successfully")
                    storageRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            let stringValue = downloadURL.absoluteString
                            self.uploadRequestToFirestore(fileUrl: stringValue)
                        }
                    }
                }
            }
        }
    }
    
    func uploadRequestToFirestore(fileUrl: String){
        let requestModel = RequestModel(productname: self.productNameTxt.text ?? "", warehouseID: self.warehouseIdTxt.text ?? "", upcNumber: self.upcTxt.text ?? "", quantity: self.quantityTxt.text ?? "", shippingFile: fileUrl, userid: UserDefaultsManager.shared.getDocumentId(), managerid: self.productData?.managerid ?? "", requestId: "\(self.productData?.productname ?? "")-\(self.productData?.upcNumber ?? "")-\(self.quantityTxt.text ?? "")-\(UserDefaultsManager.shared.getDocumentId())", category: self.productData?.category ?? "", availableQuantity: self.productData?.availableQuantity ?? "",managerEmail: self.productData?.managerEmail ?? "", userEmail: UserDefaultsManager.shared.getEmail(), price: self.productData?.price ?? "20.0", paymentStatus: self.productData?.paymentStatus ?? "", trackingNumber: "", status_accepted_rejected: "", packageStatus: "")
        
        FireStoreManager.shared.addProductRequest(warehouseID: self.warehouseIdTxt.text ?? "", UPC: self.upcTxt.text ?? "", request: requestModel) { success in
            if success{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    showAlerOnTop(message: "Product request sent successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                showAlerOnTop(message: "You already sent request or Product detail not found!")
            }
        }
    }
}
