//
//  LCToastTableViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import LSExtensions
import RxSwift
import RxCocoa
import CoreData

class LCToastTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    static let CellID = "LCToastTableViewCell";
    
    lazy var favoriteController : LCFavoriteModelViewController! = LCFavoriteModelViewController(self);
    private(set) var toasts : Variable<[LCToast]>
        = Variable<[LCToast]>([]);
    
    lazy var filteredToasts : Observable<[LCToast]> = {
        return self.toasts.asObservable();
    }()
    
    lazy var currentCategory : LCToastCategory! = {
        return LCExcelController.shared.categories.first { (category) -> Bool in
            return category.name == self.category;
        }
    }()
    
    func updateToasts(){
        var value = self.currentCategory?.toasts ?? [];
        
        //Filters toasts by keyword
        if self.searchBar.text?.isEmpty == false{
            value = value.filter({ (toast) -> Bool in
                return toast.title.contains(self.searchBar.text ?? "");
            });
        }
        
        self.toasts.value = value;
    }
    
    var category : String?;
    var modelController : LCModelController{
        get{
            return LCModelController.shared;
        }
    }
    
    var background : UIImage?;
    var backgroundView : UIImageView?;
    
//    var searchBar : UISearchBar!;
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func onRandomButton(_ sender: UIBarButtonItem) {
        // MARK: Shows random toast with alert
        let toast = LCExcelController.shared.randomToast(self.category ?? "");
        //self.showAlert(title: toast.title, msg: toast.contents, actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
        self.popupAndShare(title: toast.title, contents: toast.contents);
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.favoriteController;
        self.updateToasts();
        self.setupCellGeneration();
        
        // MARK: Sets background image if there is image for the category
        guard self.background != nil else{
            return;
        }
        
        self.backgroundView = UIImageView(frame: self.tableView.frame);
        self.backgroundView?.contentMode = .scaleAspectFill;
        self.backgroundView?.alpha = 0.2;
        self.backgroundView?.image = self.background;
        self.backgroundView?.backgroundColor = .white;
        self.tableView.addSubview(self.backgroundView!);
        self.tableView.sendSubviewToBack(self.backgroundView!);
        
        AppDelegate.sharedGADManager?.show(unit: .full, completion: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var disposeBag = DisposeBag();
    func setupCellGeneration(){
        // MARK: Disables delegate for binding action
        //Unless this, the app will be crashed by conflict
        //self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        
        // MARK: Binds categories to tableView
        self.disposeBag = self.filteredToasts.bindTableView(to: self.tableView, cellIdentifier: type(of: self).CellID, cellType: LCToastTableViewCell.self) { [unowned self](row, toast, cell) in
            cell.nameLabel.text = toast.title;
            cell.contentLabel.text = toast.contents;
            cell.selectedBackgroundView = UIView();
            //cell?.selectedBackgroundView.alpha = 0.5;
            
            //        cell.textLabel?.text = toast.title;
            // Configure the cell...
            cell.favoriteButton.addTarget(self, action: #selector(self.onCheckFav(button:)), for: .touchUpInside);
            
            let isFav = self.modelController.isExistFavorite(withName: cell.nameLabel.text ?? "") ? true : false;
            
            let img = cell.favoriteButton.image(for: .selected)?.withRenderingMode(.alwaysTemplate);
            cell.favoriteButton.setImage(img, for: .selected);
            
            cell.favoriteButton.isSelected = isFav;
            print("check cell[\(row.description)] name[\(cell.nameLabel.text?.description ?? "")] button[\(cell.favoriteButton.description)] selected[\(isFav.description)]");
        }
    }
    
    @IBAction func onCheckFav(button : UIButton){
        let cell = button.superview?.superview as! LCToastTableViewCell;
        let value = !button.isSelected;
        
        let toast = self.modelController.findFavorite(withName: cell.nameLabel.text ?? "").first;
        if cell.favoriteButton.isSelected{
            guard toast != nil else{
                return;
            }
            
            self.modelController.removeFavorite(toast: toast!);
        }else{
            guard toast == nil else{
                return;
            }
            
            let fav = self.modelController.createFavorite(name: cell.nameLabel.text ?? "", contents: cell.contentLabel.text ?? "");
            fav.category = self.category;
        }
        
        cell.favoriteButton.isSelected = value;
        self.modelController.saveChanges();
        //        var stock : RSStoredStock?;
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        self.updateToasts();
        return self.toasts.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LCToastTableViewController.CellID, for: indexPath) as? LCToastTableViewCell;

        let toast = self.toasts[indexPath.row];
        cell?.nameLabel.text = toast.title;
        cell?.contentLabel.text = toast.contents;
        cell?.selectedBackgroundView = UIView();
        //cell?.selectedBackgroundView.alpha = 0.5;
        
//        cell.textLabel?.text = toast.title;
        // Configure the cell...
        cell?.favoriteButton.addTarget(self, action: #selector(onCheckFav(button:)), for: .touchUpInside);
        
        let isFav = self.modelController.isExistFavorite(withName: cell?.nameLabel.text ?? "") ? true : false;
        
        let img = cell?.favoriteButton.image(for: .selected)?.withRenderingMode(.alwaysTemplate);
        cell?.favoriteButton.setImage(img, for: .selected);
        
        cell?.favoriteButton.isSelected = isFav;
        print("check cell[\(indexPath.row.description)] name[\(cell?.nameLabel.text?.description ?? "")] button[\(cell?.favoriteButton.description ?? "")] selected[\(isFav.description)]");
        
        return cell!;
    }*/

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : LCToastTableViewCell! = tableView.cellForRow(at: indexPath) as? LCToastTableViewCell;
        
        guard cell != nil else{
            return;
        }
        //return;
        
        let name = cell?.nameLabel?.text ?? "";
        let contents = cell?.contentLabel?.text ?? "";
//        if !contents.isEmpty{
//            contents = "\n- " + contents;
//        }
//        contents = contents + "\n#" + self.displayAppName;
        //let msg = "\(name)\(contents)";
        
        self.popupAndShare(title: name, contents: contents);

//        self.share([msg]);
    }
    
    func popupAndShare(title : String, contents: String){
        var contents = contents;
        
//        var msg = "\(title)\(contents)";
        
        self.showAlert(title: title, msg: contents, actions: [UIAlertAction(title: "공유", style: .default, handler: {(act) -> Void in
            if !contents.isEmpty{
                contents = "\n- " + contents;
            }
            
            let tag = (UIApplication.shared.displayName != nil) ? "" : "\n#" + UIApplication.shared.displayName!;
            self.share([title + contents + tag]);
        }), UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.backgroundView?.frame.origin.y = self.view.frame.maxY - (self.backgroundView?.frame.height ?? 0);
        self.backgroundView?.frame.origin.y = scrollView.contentOffset.y;
    }
    
    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.updateToasts();
        self.tableView.reloadData();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        self.updateToasts();
        searchBar.resignFirstResponder();
        self.tableView.reloadData();
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }

    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            case .insert:
                print("inserting favorite is detected in toast tableView");
                break;
            case .delete:
                print("deleting favorite is detected in toast tableView");
                guard let favorite = anObject as? FavoriteToast else{
                    return;
                }
                
                guard let toastIndex = self.toasts.value.firstIndex(where: { $0.title == favorite.name }) else{
                    return;
                }
                
                let cell = self.tableView.cellForRow(at: IndexPath.init(row: toastIndex, section: 0)) as? LCToastTableViewCell;
                cell?.favoriteButton.isSelected = false;
                //self.tableView.deleteRows(at: [indexPath!], with: .fade);
                break;
        default:
            break;
        }
    }
    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        AppDelegate.sharedGADManager?.show(unit: .full) { [weak self](unit, ad, result) in
//            self?.performSegue(withIdentifier: identifier, sender: sender);
//        }
//
//        return false;
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
