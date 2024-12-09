//
//  ProductList.swift
//  SmartInventory
//
//  Created by Deepika Kunwar on 19/11/24.
//

import UIKit

class ProductListVC: BaseVC {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Child View Controllers
    var productRequestViewController: InventoryListVC!
    var historyViewController: PackageListVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        productRequestViewController = storyboard.instantiateViewController(withIdentifier: "InventoryListVC") as? InventoryListVC
        historyViewController = storyboard.instantiateViewController(withIdentifier: "PackageListVC") as? PackageListVC
        
        displayCurrentViewController(selectedSegmentIndex: segmentedControl.selectedSegmentIndex)
    }
    
    // MARK: - Segment Control Action
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        displayCurrentViewController(selectedSegmentIndex: sender.selectedSegmentIndex)
    }
    
    // MARK: - Switch between child view controllers
    func displayCurrentViewController(selectedSegmentIndex: Int) {
        // Remove existing child view controller
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        // Add the new child view controller based on selected segment
        switch selectedSegmentIndex {
        case 0:
            embedChildViewController(productRequestViewController)
        case 1:
            embedChildViewController(historyViewController)
        default:
            break
        }
    }
    
    // MARK: - Add child view controller method
    func embedChildViewController(_ viewController: UIViewController) {
        addChild(viewController)
        
        viewController.view.frame = containerView.bounds
        
        containerView.addSubview(viewController.view)
        
        viewController.didMove(toParent: self)
    }
}



