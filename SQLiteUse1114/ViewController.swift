
//
//  ViewController.swift
//  SQLiteUse1114
//
//  Created by 502 on 2018. 11. 14..
//  Copyright © 2018년 502. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //데이터베이스 파일 경로를 저장할 변수
    var dbPath : String?
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    //@IBOutlet weak var status: UILabel!
   // @IBOutlet weak var txtName: UITextField!
   // @IBOutlet weak var txtPhone: UITextField!
   // @IBOutlet weak var txtAddress: UITextField!
    
    //저장하는 버튼
    @IBAction func save(_ sender: Any) {
        //데이터 가져오기
        let name = txtName!.text
        let phone = txtPhone!.text
        let address = txtAddress!.text
        
        //데이터베이스 열기
        let contactDB = FMDatabase(path: dbPath!)
        if contactDB.open(){
            //sql 생성
            let sql = "insert into contacts(name, phone, address) values(?,?,?)"
            //sql 실행
            let result = contactDB.executeUpdate(sql, withArgumentsIn: [name!, phone!, address!])
            if !result{
                status.text = "삽입 실패"
            }else{
                status.text = "삽입 성공"
                txtName!.text = ""
                txtPhone!.text = ""
                txtAddress!.text = ""
            }
            contactDB.close()
        }
    }
    
    //조회하는 버튼
    @IBAction func read(_ sender: Any) {
        //데이터베이스 열기
        let contactDB = FMDatabase(path: dbPath!)
        if contactDB.open(){
            //테이블의 모든 데이터를 가져오는 SQL을 생성
            let sql = "select name, phone, address from contacts"
            //select 구문은 ResultSet으로 받아야 합니다.
            let results:FMResultSet? =
                contactDB.executeQuery(sql, withArgumentsIn:[])
            if results!.next() == true{
                txtName!.text = results!.string(forColumn: "name")
                txtPhone!.text = results!.string(forColumn: "phone")
                txtAddress!.text = results!.string(forColumn: "address")
                
            }else{
                status.text = "읽을 데이터가 없음"
            }
            
        }else{
            status.text = "DB 열기 실패"
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //데이터베이스 파일의 경로 생성
        let fileMgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docPath = dirPaths[0] as String
        dbPath = docPath.appending("/contact.sqlite")
        
        //파일의 존재여부 확인
        if !fileMgr.fileExists(atPath: dbPath!){
            //파일을 생성
            let contactDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            if contactDB.open(){
                let sql = "create table contacts(id integer primary key autoincrement, name text, phone text, address text)"
                if !contactDB.executeStatements(sql){
                    status.text = "테이블 생성 실패"
                }
            }else{
                status.text = "데이터베이스 열기 실패"
            }
        }else{
            status.text = "파일이 존재"
        }
    }
    
    
}


