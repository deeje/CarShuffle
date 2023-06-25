//
//  Created by deeje cooley on 10/10/18.
//  Copyright © 2018 deeje LLC.  All rights reserved.
//

import Eureka
import CoreData
import CloudCore

final class DestructiveButtonRow : _ButtonRowOf<String>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    override func customUpdateCell() {
        super.customUpdateCell()
        cell.textLabel?.textColor = UIColor.red
    }
}

class CarEditor: FormViewController {
    
    var persistentContainer: NSPersistentContainer
    var carID: NSManagedObjectID?
    var carObject: Car?
    
    lazy var shareButton: UIBarButtonItem = {
        let config = UIImage.SymbolConfiguration(weight: .regular)
        let shareImage = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        
        return UIBarButtonItem.init(image: shareImage, style: .plain, target: self, action: #selector(shareProfile))
    }()
    var sharingController: CloudCoreSharingController?
    var waitingForConfiguredShareController = false {
        didSet {
            configureUIforEditable()
        }
    }
    
    private var editable: Bool = false {
        didSet {
            configureUIforEditable()
        }
    }
    
    enum Keys: String {
        case name
        
        func key() -> String {
            return rawValue
        }
        
        func title() -> String {
            switch self {
            default:
                return rawValue.capitalized
            }
        }
    }
    
    init(persistentContainer: NSPersistentContainer, carID: NSManagedObjectID?) {
        self.persistentContainer = persistentContainer
        self.carID = carID
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(doCancel))
        
        if carID != nil {
            carObject = (try? persistentContainer.viewContext.existingObject(with: carID!)) as? Car
            
            carObject?.fetchEditablePermissions { isEditable in
                self.editable = isEditable
            }
        } else {
            editable = true
        }
        
        form
            +++ Section()
            
            
            <<< TextRow() {
                $0.tag = Keys.name.key()
                $0.title = Keys.name.title()
                
                $0.value = carObject?.name
            }
            
            +++ Section("")
        
            <<< DestructiveButtonRow {
                $0.title = "Delete"
                $0.hidden = .function([]) { form in
                    return self.carObject == nil
                }
            }
            .onCellSelection { [weak self] (cell, row) in
                self?.confirmDelete()
            }
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
        
        configureUIforEditable()
    }
    
    func configureUIforEditable() {
        var buttons: [UIBarButtonItem] = []
        
        if editable {
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(doSave))
            buttons.append(saveButton)
        }
        
        // TODO: is this fixed in recent Catalyst?!
        let addShareButton = !ProcessInfo.processInfo.isMacCatalystApp
        
        if addShareButton == true {
            if waitingForConfiguredShareController {
                let uiBusy = UIActivityIndicatorView(style: .medium)
                uiBusy.hidesWhenStopped = true
                uiBusy.startAnimating()
                let uiBusyButton = UIBarButtonItem(customView: uiBusy)
                buttons.append(uiBusyButton)
            } else {
                buttons.append(shareButton)
            }
        }
                
        self.navigationItem.rightBarButtonItems = buttons
        
        for row in form.rows {
            if ["open", "add"].contains(row.tag) == false {
                row.baseCell.isUserInteractionEnabled = editable
            }
        }
    }
    
    @IBAction func shareProfile() {
        if waitingForConfiguredShareController { return }
        
        iCloudAvailable { available in
            guard available else { return }
            
            self.waitingForConfiguredShareController = true
            if self.sharingController == nil {
                self.sharingController = CloudCoreSharingController(persistentContainer: self.persistentContainer,
                                                                    object: self.carObject!)
            }
            self.sharingController?.configureSharingController(permissions: [.allowReadWrite, .allowPrivate]) { csc in
                self.presentActivities(with: csc)
            }
        }
    }
    
    func presentActivities(with sharingController: UICloudSharingController?) {
        waitingForConfiguredShareController = false
        
        if let csc = sharingController {
            csc.popoverPresentationController?.barButtonItem = shareButton
            self.present(csc, animated:true, completion:nil)
        }
    }
    
    func confirmDelete() {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This will be permanently removed this car from all devices", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.persistentContainer.performBackgroundPushTask { moc in
                if let carToDelete = try? moc.existingObject(with: self.carID!) {
                    moc.delete(carToDelete)
                    try? moc.save()
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirm)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @objc func doCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doSave() {
        let values = form.values()
        
        persistentContainer.performBackgroundPushTask { moc in
            var carToUpdate: Car?
            if self.carID != nil {
                carToUpdate = (try? moc.existingObject(with: self.carID!)) as? Car
            }
            if carToUpdate == nil {
                carToUpdate = Car(context: moc)
            }
            carToUpdate?.name = values[Keys.name.key()] as? String
            
            do {
                try moc.save()
            } catch {
                print("Unexpected error: \(error).")
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
