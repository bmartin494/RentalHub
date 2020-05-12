//
//  PropertyViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 31/03/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import Firebase

class PropertyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    let cellID = "cellID"
    
    @IBOutlet weak var addPropertyNavButton: UIBarButtonItem!
    @IBOutlet weak var portfolioTitleLabel: UILabel!
    @IBOutlet weak var portfolioTableView: UITableView!
    @IBOutlet weak var landlordExplationLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countyTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var linkPropertyTitleLabel: UILabel!
    @IBOutlet weak var tenantRequestTitle: UILabel!
    @IBOutlet weak var createPropertyButton: UIButton!
    @IBOutlet weak var addPropertyButton: UIBarButtonItem!
    @IBOutlet weak var tenantRequestTableView: UITableView!
    @IBOutlet weak var linkPropertyButton: UIButton!
    @IBOutlet weak var submitDetailsButton: UIButton!
    @IBOutlet weak var rentTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDateTitle: UILabel!
    @IBOutlet weak var rentTitle: UILabel!
    @IBOutlet weak var rentStackView: UIStackView!
    @IBOutlet weak var dueDateStackView: UIStackView!
    
    
    
    var propertiesCollectionRef = Firestore.firestore().collection("properties")
    var documentsCollectionRef = Firestore.firestore().collection("documents")
    var usersCollectionRef = Firestore.firestore().collection("users")
    var requestsCollectionRef = Firestore.firestore().collection("requests")
    var properties = [Property]()
    var requests = [Request]()
    var documents = [Document]()
    var currentUser = Auth.auth().currentUser
    var userType: Int?
    var linkRequest: Bool? = false
    var userDocID: String?
    var userAccountID: String?
    var myIndex = 0
    var tenantName: String?
    var firstname: String?
    var propertyID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portfolioTableView.register(ReportCell.self, forCellReuseIdentifier: cellID)
        tenantRequestTableView.register(ReportCell.self, forCellReuseIdentifier: cellID)
        portfolioTableView.delegate = self
        portfolioTableView.dataSource = self
        portfolioTableView.rowHeight = UITableView.automaticDimension
        portfolioTableView.tableFooterView = UIView()
        
        tenantRequestTableView.delegate = self
        tenantRequestTableView.dataSource = self
        tenantRequestTableView.rowHeight = UITableView.automaticDimension
        tenantRequestTableView.tableFooterView = UIView()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkUserType()
    }
    
    
    func checkUserType() {
        
        //Checking whether tenant or landlord user
        usersCollectionRef.whereField("uid", isEqualTo: currentUser!.uid).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                for document in snapshot!.documents {
                    let data = document.data()
                    self.userAccountID = data["uid"] as? String
                    self.userType = data["Account_Type"] as? Int
                    self.linkRequest = data["LinkRequest_Sent"] as? Bool
                    self.userDocID = document.documentID
                    self.firstname = document["First_Name"] as? String
                    let lastname = document["Last_Name"] as? String
                    self.tenantName = self.firstname! + " " + lastname!
                    self.propertyID = data["Assigned_Property"] as? String
                    
                    //checking whether tenant or landlord user
                    if self.userType == 0 && self.linkRequest == false {
                        self.portfolioTitleLabel.isHidden = false
                        self.portfolioTitleLabel.text = "Your property"
                        self.landlordExplationLabel.isHidden = false
                        self.landlordExplationLabel.text = "You have not yet linked your account to a landlord's property. This easiest way to do this is to enter the property ID provided by your landlord to request a direct link. Alternatively if you cannot provide your property ID, enter their email and you will be prompted to provide some additional information about the property so your request can be matched."
                        self.addressTextField.isHidden = false
                        self.addressTextField.placeholder = "Landlord email / property ID"
                        self.linkPropertyButton.isHidden = false
                    }
                    else if self.userType == 0 && self.linkRequest == true && self.propertyID == "" {
                        self.linkRequestSent()
                    }
                    else if self.userType == 0 && self.linkRequest == true && self.propertyID != "" {
                        self.getPropertyDocuments()
                        self.loadAssignedTenant()
                    }
                    else {
                        self.getLandlordProperties()
                        self.getTenantRequests()
                        
                    }
                }
            }
        }
    }
    
    
    func loadAssignedTenant() {
        
        var rent: String?
        var dueDate: String?
        
        propertiesCollectionRef.whereField("PropertyID", isEqualTo: propertyID!).getDocuments { (snapshot, error) in
        if let err = error {
            debugPrint("Error fetching docs: \(err)")
        }
        else {
            for document in snapshot!.documents {
                let data = document.data()
                rent = data["Rent"] as? String
                dueDate = data["Due_Date"] as? String
                
            }
            
            self.rentLabel.text = rent
            self.dueDateLabel.text = dueDate

        }}
        
        self.portfolioTitleLabel.isHidden = false
        self.portfolioTitleLabel.text = "Hello, " + (firstname ?? "")
        self.landlordExplationLabel.isHidden = false
        self.landlordExplationLabel.text = "Property details"
        self.tenantRequestTitle.isHidden = false
        self.tenantRequestTitle.text = "Property noticeboard"
        
        self.tenantRequestTableView.isHidden = false
        self.tenantRequestTableView.reloadData()
        self.rentStackView.isHidden = false
        self.dueDateStackView.isHidden = false

    }
    
    
    func getPropertyDocuments() {
        
        
        documentsCollectionRef.whereField("PropertyID", isEqualTo: propertyID!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                self.documents.removeAll()
                if snapshot!.count > 0 {
                    for document in snapshot!.documents {
                        let data = document.data()
                        let documentID = document.documentID as String
                        let propertyID = data["PropertyID"] as? String
                        let docTitle = data["Title"] as? String
                        let mainDocument = data["Body"] as? String
                        let notes = data["Notes"] as? String
                        let date = data["Date"] as? String
                        let signatureCount = data["Signature_Count"] as? Int
                        let signatures = data["Signatures"] as? Array<String>
                        let signature = data["Require_Signature"] as? Bool
                        let imageURL = data["ImageURL"] as? String
                        
                        let newDocument = Document()
                        newDocument.documentID = documentID
                        newDocument.propertyID = propertyID
                        newDocument.title = docTitle
                        newDocument.mainDocument = mainDocument
                        newDocument.notes = notes
                        newDocument.date = date
                        newDocument.signatureCount = signatureCount
                        newDocument.signatures = signatures ?? []
                        newDocument.signatureRequired = signature
                        newDocument.imageURL = imageURL
                        
                        self.documents.append(newDocument)
                    }
                    self.tenantRequestTableView.reloadData()
                }
            }
        }
    }
    
    func getLandlordProperties() {
        
        propertiesCollectionRef.whereField("LandlordID", isEqualTo: currentUser!.uid).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                self.properties.removeAll()
                if snapshot!.count > 0 {
                    for document in snapshot!.documents {
                        let data = document.data()
                        let address = data["Address"] as? String
                        let city = data["City"] as? String
                        let county = data["County"] as? String
                        let postcode = data["Postcode"] as? String
                        let landlordID = data["LandlordID"] as? String
                        let propertyID = data["PropertyID"] as? String
                        let rent = data["Rent"] as? String
                        let dueDate = data["Due_Date"] as? String
                        let tenants = data["Tenants"] as? Array<String>
                        
                        let newProperty = Property()
                        newProperty.address = address
                        newProperty.city = city
                        newProperty.county = county
                        newProperty.postcode = postcode
                        newProperty.dueDate = dueDate
                        newProperty.rent = rent
                        newProperty.landlordID = landlordID
                        newProperty.propertyID = propertyID
                        newProperty.tenants = tenants ?? []
                        
                        self.properties.append(newProperty)
                        
                        self.portfolioTitleLabel.isHidden = false
                        self.portfolioTitleLabel.text = "Your portfolio"
                        self.landlordExplationLabel.isHidden = true
                        self.addressTextField.isHidden = true
                        self.cityTextField.isHidden  = true
                        self.countyTextField.isHidden = true
                        self.linkPropertyTitleLabel.isHidden = true
                        self.postcodeTextField.isHidden = true
                        self.portfolioTableView.isHidden = false
                        self.portfolioTableView.isUserInteractionEnabled = true
                        self.addPropertyNavButton.image = .add
                        self.tenantRequestTitle.isHidden = false
                        self.tenantRequestTableView.isHidden = false
                    }
                }
                else {
                    self.portfolioTitleLabel.text = "Your portfolio"
                    self.portfolioTitleLabel.isHidden = false
                    self.landlordExplationLabel.isHidden = false
                    self.portfolioTitleLabel.isHidden = false
                    self.addressTextField.isHidden = false
                    self.cityTextField.isHidden  = false
                    self.countyTextField.isHidden = false
                    self.postcodeTextField.isHidden = false
                    self.createPropertyButton.isHidden = false
                    self.rentTextField.isHidden = false
                    self.dueDateTextField.isHidden = false
                    self.linkPropertyTitleLabel.text = "Link a new property"
                    self.landlordExplationLabel.text = "You do not have any properties linked to this account. Create a property below to add one to your portfolio. You can then add tenants to each property by sharing the unique property ID and accepting tenant requests."
                }
                
            }
            
            self.portfolioTableView.reloadData()
            
        }
    }
    
    
    
    func getTenantRequests() {
        
        requests.removeAll()
        
        requestsCollectionRef.whereField("Landlord_Email", isEqualTo: currentUser!.email!).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            }
            else {
                if snapshot!.count > 0 {
                    for document in snapshot!.documents {
                        let data = document.data()
                        let tenantEmail = data["Tenant_Email"] as? String
                        let address = data["Address"] as? String
                        let postcode = data["Postcode"] as? String
                        let landlordEmail = data["Landlord_Email"] as? String
                        let requestID = document.documentID
                        let tenantName = data["Tenant_Name"] as? String
                        let propertyID = data["PropertyID"] as? String
                        let requestDate = data["Date"] as? String
                        let tenantID = data["TenantID"] as? String
                        
                        let newRequest = Request()
                        newRequest.tenantEmail = tenantEmail
                        newRequest.address = address
                        newRequest.postcode = postcode
                        newRequest.landlordEmail = landlordEmail
                        newRequest.tenantID = tenantID
                        newRequest.requestID = requestID
                        newRequest.tenantName = tenantName
                        newRequest.date = requestDate
                        newRequest.propertyID = propertyID
                        self.requests.append(newRequest)
                    }
                }
                self.tenantRequestTableView.reloadData()
                
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPropertyID(_ uuid: String) -> Bool {
        let uuidRegEx = "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}"
        
        let uuidPred = NSPredicate(format:"SELF MATCHES %@", uuidRegEx)
        return uuidPred.evaluate(with: uuid)
    }
    
    
    @IBAction func linkPropertyTapped(_ sender: Any) {
        
        let linkingInput = self.addressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var documentID: String? = ""
        var address: String?
        var postcode: String?
        var landlordEmail: String?
        var landlordID: String?
        let emailCheck = isValidEmail(linkingInput)
        let propertyIDCheck = isValidPropertyID(linkingInput)
        
        
        //if tenant provides property ID for linking
        if propertyIDCheck == true {
            
            propertiesCollectionRef.whereField("PropertyID", isEqualTo: linkingInput).getDocuments { (snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else {
                    for document in snapshot!.documents {
                        let data = document.data()
                        documentID = document.documentID as String
                        address = data["Address"] as? String
                        postcode = data["Postcode"] as? String
                        landlordEmail = data["Landlord_Email"] as? String
                        landlordID = data["LandlordID"] as? String
                    }
                }
                if documentID != "" {
                    self.propertiesCollectionRef.document(documentID!).updateData([
                        "Requests": FieldValue.arrayUnion([self.currentUser!.uid])])
                    
                    let today = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM.yy"
                    let formattedDate = dateFormatter.string(from: today)
                    
                    let db = Firestore.firestore()
                    db.collection("requests").addDocument(data: ["TenantID":self.userAccountID!, "Tenant_Email" : self.currentUser!.email!, "Address": address ?? "Address could not be saved", "LandlordID": landlordID ?? "Could not retrieve landlord ID","PropertyID" : linkingInput, "Postcode" : postcode ?? "Postcode could not be saved", "Tenant_Name" : self.tenantName ?? "Could not retrieve tenant name","Landlord_Email" : landlordEmail ?? "Landlord email could not be saved", "Date": formattedDate]) { (error) in
                        if error != nil {
                            print(error!)
                        }
                    }
                    
                    self.linkRequestSent()
                }
            }
        }
        else if emailCheck == true{
            
            self.landlordExplationLabel.isHidden = false
            self.landlordExplationLabel.text = "It appears you have entered a landlord's email, could you please tell us a bit more about the property you are looking to link?"
            
            self.cityTextField.isHidden = false
            self.cityTextField.placeholder = "Street address"
            self.postcodeTextField.isHidden = false
            self.postcodeTextField.placeholder = "Postcode"
            self.linkPropertyButton.isHidden = true
            self.submitDetailsButton.isHidden = false
            
        }
        else {
            self.landlordExplationLabel.isHidden = false
            self.landlordExplationLabel.text = "You have not entered a correctly formatted Property ID or landlord email, please try again."
        }
        
    }
    
    
    @IBAction func submitDetailsTapped(_ sender: Any) {
        
        let db = Firestore.firestore()
        let email = self.addressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = self.cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let postcode = self.postcodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: today)
        
        db.collection("requests").addDocument(data: ["TenantID":userAccountID!, "Tenant_Email" : currentUser!.email!, "Address": address, "Postcode" : postcode, "Landlord_Email" : email, "Date": formattedDate]) { (error) in
            if error != nil {
                print(error!)
            }
            else {
                self.linkRequestSent()
            }
        }
    }
    
    
    
    func linkRequestSent() {
        
        self.portfolioTitleLabel.isHidden = true
        self.portfolioTitleLabel.text = "Your property"
        self.landlordExplationLabel.isHidden = false
        self.addressTextField.isHidden = true
        self.landlordExplationLabel.text = "Your  link request has been sent to your landlord. Once they accept the request you will be able to view your property on this page, access documents and make requests."
        linkRequest = true
        linkPropertyButton.isHidden = true
        
        if userDocID != ""{
            self.usersCollectionRef.document(self.userDocID!).updateData(["LinkRequest_Sent" : true]) { (error) in
                if error != nil {
                    print(error!)
                }
            }
        }
    }
    
    
    
    //landlord creating new property
    @IBAction func createPropertyTapped(_ sender: Any) {
        
        let propertyID = UUID().uuidString
        
        if addressTextField.isHidden == true {
            performSegue(withIdentifier: "createProperty", sender: self)
        }
        else {
            //validate the fields
            let error = validateFields()
            if error != nil {
                //something wrong with field inputs, show error message
                let alert = UIAlertController(title: "Fields incomplete", message: "Please fill out all fields in order to create a new property.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else {
                
                //create cleaned versions of the data
                let address = self.addressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let city = self.cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let county = self.countyTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let postcode = self.postcodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let email = Auth.auth().currentUser!.email
                let rent = self.rentTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let dueDate = self.dueDateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                //user created successfully, storing first and last name
                let db = Firestore.firestore()
                
                db.collection("properties").addDocument( data: ["Address":address, "City":city, "County":county, "Postcode":postcode, "PropertyID":propertyID, "Landlord_Email":email!,"LandlordID":Auth.auth().currentUser!.uid,"Rent":rent,"Due_Date":dueDate,"Tenants":[]]) { (error) in
                    
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: "Could not create new property", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else {
                        
                        //change view to show landlord portfolio and any requests
                        let alert = UIAlertController(title: "Property created", message: "You can now view this property in the portfolio section", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                        self.addressTextField.text = nil
                        self.cityTextField.text = nil
                        self.countyTextField.text = nil
                        self.postcodeTextField.text = nil
                        
                        self.addressTextField.isHidden = true
                        self.cityTextField.isHidden = true
                        self.countyTextField.isHidden = true
                        self.postcodeTextField.isHidden = true
                        self.createPropertyButton.isHidden = true
                        self.landlordExplationLabel.isHidden = true
                        self.rentTextField.isHidden = true
                        self.dueDateTextField.isHidden = true
            
                        self.getLandlordProperties()
                        self.portfolioTableView.isHidden = false
                        self.portfolioTitleLabel.text = "Your portfolio"
                        self.tenantRequestTitle.isHidden = false
                        self.tenantRequestTableView.isHidden = false
                        
                    }
                }
            }
        }
    }
    
    
    
    //segue for top right nav button for landlord to create new property
    @IBAction func addPropertyTapped(_ sender: Any) {
        performSegue(withIdentifier: "createProperty", sender: self)
    }
    
    
    
    //checks input fields, if valid returns nil, if not returns error message
    func validateFields() -> String? {
        //check all fields filled
        if addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            countyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            postcodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Fields incomplete"
        }
        
        return nil
    }
    
    
    
    //table view functionality from here onwards
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == portfolioTableView {
            if properties.count > 0 {
                return properties.count
            }
            else {
                return 1
            }
        }
        else if tableView == tenantRequestTableView{
            
            if userType == 1 {
                if requests.count > 0 {
                    return requests.count
                }
                else {
                    return 1
                }
            }
            else {
                if documents.count > 0{
                    return documents.count
                }
                else {
                    return 1
                }
            }
        }
        else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.tertiarySystemGroupedBackground

        if tableView == portfolioTableView {
            if properties.count <= 0 {
                portfolioTableView.allowsSelection = false
                cell.textLabel?.text = ""
            }
            else {
                let property = properties[indexPath.row]
                portfolioTableView.allowsSelection = true
                cell.textLabel?.text = property.address

            }
        }
        
        if tableView == tenantRequestTableView {
            
            if userType == 1 {
                if requests.count <= 0 {
                    cell.textLabel?.text = "You currently have no requests"
                    cell.detailTextLabel?.isHidden = true
                    tenantRequestTableView.allowsSelection = false

                }
                else {
                    let request = requests[indexPath.row]
                    tenantRequestTableView.allowsSelection = true
                    cell.textLabel?.text = request.tenantName
                    cell.detailTextLabel?.text = request.address

                }
            }
            
            else if userType == 0 {
                if documents.count <= 0 {
                    cell.textLabel?.text = "You currently have no documents"
                    cell.detailTextLabel?.isHidden = true
                    tenantRequestTableView.allowsSelection = false
                }
                else {
                    let document = documents[indexPath.row]
                    tenantRequestTableView.allowsSelection = true
                    cell.textLabel?.text = document.title
                    cell.detailTextLabel?.isHidden = false
                    cell.detailTextLabel?.text = document.date
                }

            }
            
        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        myIndex = indexPath.row
        if tableView == portfolioTableView{
            performSegue(withIdentifier: "showProperty", sender: self)
        }
        
        if tableView == tenantRequestTableView{
            if requests.count > 0 && userType == 1 {
                performSegue(withIdentifier: "showRequest", sender: self)
            }
            
            if documents.count > 0 && userType == 0 {
                performSegue(withIdentifier: "showFullDocumentTenant", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? FullPropertyViewController {
            let property = properties[myIndex]
            
            destination.addressText = property.address
            destination.cityText = property.city
            destination.countyText = property.county
            destination.postcodeText = property.postcode
            destination.propertyID = property.propertyID
            
        }
        
        if let destination = segue.destination as? RequestViewController {
            let request = requests[myIndex]
            
            destination.tenantName = request.tenantName
            destination.tenantEmail = request.tenantEmail
            destination.address = request.address
            destination.postcode = request.postcode
            destination.date = request.date
            destination.propertyID = request.propertyID
            destination.tenantID  = request.tenantID
            destination.requestID = request.requestID
        }
        
        if let destination = segue.destination as? FullDocumentViewController {
            let document = documents[myIndex]
            
            destination.document.documentID = document.documentID
            destination.document.propertyID = document.propertyID
            destination.document.title = document.title
            destination.document.mainDocument = document.mainDocument
            destination.document.notes = document.notes
            destination.document.date = document.date
            destination.document.signatures = document.signatures
            if document.imageURL != nil {
                destination.document.imageURL = document.imageURL
            }
            destination.document.signatureCount = document.signatureCount
            destination.document.signatureRequired = document.signatureRequired
            
        }
        
    }
    
    
    @IBAction func unwindToPropertyView( _ seg: UIStoryboardSegue) {}
}





