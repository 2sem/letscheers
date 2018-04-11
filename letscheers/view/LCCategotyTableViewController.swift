//
//  LCCategotyTableViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LCCategotyTableViewController: UITableViewController {
    static let CellID = "LCCategoryTableViewCell";

    var categories : Variable<[LCToastCategory]>
        = Variable<[LCToastCategory]>([]);
    
    lazy var filteredCategories : Observable<[LCToastCategory]> = {
        return self.categories.asObservable();
    }()

    @IBOutlet var shareButton: UIBarButtonItem!;
    @IBAction func onRandomButton(_ button: UIBarButtonItem) {
        var toast = LCExcelController.shared.randomToast();
        self.showAlert(title: toast.title, msg: toast.contents, actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.setupCellGeneration();
        
        self.loadCategories();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCategories(){
        self.categories.value.append(LCToastCategory(name: "선창!후창~!", title: "선/후창 건배사", image: UIImage(named: "bg_follow.jpg")));
        self.categories.value.append(LCToastCategory(name: "모임", title: "모임용 건배사", image: UIImage(named: "bg_meeting.jpg")));
        self.categories.value.append(LCToastCategory(name: "회식", title: "회식용 건배사", image: UIImage(named: "bg_dining.jpg")));
        self.categories.value.append(LCToastCategory(name: "건강", title: "건강기원 건배사", image: UIImage(named: "bg_health.jpg")));
        LCExcelController.shared.loadCategories(categories: self.categories.value);
        var follow = self.categories.value[0];
        LCExcelController.shared.loadFollowToasts(withCategory: follow);
        LCExcelController.shared.categories = self.categories.value;
    }
    
    var disposeBag = DisposeBag();
    func setupCellGeneration(){
        //self.filteredCategories?.bind(to: self.tableView).
        //let items = Observable.just(["a", "b", "c"])
        //self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        self.filteredCategories
            .bind(to: self.tableView.rx.items(cellIdentifier: LCCategotyTableViewController.CellID, cellType: LCCategoryTableViewCell.self)){ (tableView, category, cell) in
        //items.bind(to: self.tableView.rx.items(cellIdentifier: "", cellType: UITableViewCell.self)){ (a, b, c) in
            cell.backgroundImageView.image = category.image;
            cell.titleLabel.text = category.name;
                print("create category cell. name[\(category.name)]");
        }.disposed(by: self.disposeBag);
    }

    @IBAction func onShareButton(_ button: UIBarButtonItem){
        //self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
        ReviewManager.shared?.show(true);
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.categories.value.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : LCCategoryTableViewCell!;
        
        cell = tableView.dequeueReusableCell(withIdentifier: LCCategotyTableViewController.CellID, for: indexPath) as? LCCategoryTableViewCell;
        
        var category = self.categories.value[indexPath.row];
//        cell.iconImageView.image = category.icon?.withRenderingMode(.alwaysTemplate);
        cell.backgroundImageView.image = category.image;
        cell.titleLabel.text = category.name;
        
        // Configure the cell...

        return cell
    }*/

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let view = segue.destination as? LCToastTableViewController{
//            var cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? LCCategoryTableViewCell;
            var category = self.categories.value[self.tableView.indexPathForSelectedRow!.row];
            view.category = category.name;
            view.navigationItem.title = category.title;
            view.background = category.image;
        }
    }
}
