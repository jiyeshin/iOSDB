//
//  DepartDAO.swift
//  HR1114
//
//  Created by 503-12 on 14/11/2018.
//  Copyright © 2018 The. All rights reserved.
//

import UIKit

class DepartDAO {
    //튜플(파이썬, 스위프트, 코틀린에 있는 자료형으로 서로 다른 자료형을 묶어서 저장할 수 있는 자료형)에 별명 만들기
    //스위프트나 파이썬에서는 VO 클래스 대신에 튜플을 사용하는 것을 권장하고 데이터 분석분야의 많은 메소드들이 튜플을 리턴합니다.
    typealias DepartRecord = (Int, String, String)
    
    
    //lazy init - 지연생성
    //참조형 변수의 데이터를 처음에 만들어두지 않고
    //최초로 사용을 할 때 만드는 기법
    //이 기법을 적절히 이용하면 적은 메모리를 가지고 프로그램을 실행할 수 있습니다.
    
    lazy var fmdb : FMDatabase! = {
        //파일 매니저 객체 가져오기
        let fileMgr = FileManager.default
        //도큐먼트 디렉토리의 파일 경로 만들기
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath?.appendingPathComponent("hr.sqlite").path
        //파일의 존재 여부를 확인해서 파일이 없으면 번들에서 복사
        //번들 - App 디렉토리라고 하는데 프로젝트에 포함된 파일들을 저장
        if fileMgr.fileExists(atPath:dbPath!) == false{
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath!)
        }
        //데이터베이스 열기
        let db = FMDatabase(path:dbPath)
        return db
    }()
    
    //생성자(Constructor) - init
    //생성자에는 초기화 하는 코드를 작성
    //인스턴스 변수들의 초기값 설정을 가장 많이 합니다.
    init(){
        self.fmdb.open()
    }
    
    //소멸자 - deinit
    //소멸자는 정리작업에 사용
    //외부와의 연결 객체들이 있으면 close() 하는 코드를 작성
    deinit {
        self.fmdb.close()
    }
    
    //데이터 전체를 읽어오는 메소드
    func find() -> [DepartRecord]{
        //데이터를 저장해서 리턴할 배열을 생성
        var departList = [DepartRecord]()
        
        //전체 데이터를 읽어올 SQL
        let sql = """
            select depart_cd, depart_title, depart_addr
            from department
            order by depart_cd asc
        """
        
        do{
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            while rs.next(){
                let departCd = rs.int(forColumn: "depart_cd")
                let departTitle = rs.string(forColumn: "depart_title")
                let departAddr = rs.string(forColumn: "depart_addr")
                departList.append((Int(departCd), departTitle!, departAddr!))
            }
        }catch let error as NSError{
            print("실패:\(error.localizedDescription)")
        }
        return departList
    }
    
    //기본키를 받아서 하나의 데이터를 조회하는 메소드
    func get(depart_cd : Int) -> DepartRecord?{
        let sql = """
            select depart_cd, depart_title, depart_addr
            from department
            where depart_cd = ?
        """
        //sql 실행
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [depart_cd])
        if let _rs = rs{
            _rs.next()
            let departCd = _rs.int(forColumn:"depart_cd")
            let departTitle = _rs.string(forColumn: "depart_title")
            let departAddr = _rs.string(forColumn: "depart_addr")
            return (Int(departCd), departTitle!, departAddr!)
        }else{
            return nil
        }
    }
    
    //데이터를 삽입하는 메소드
    func create(title:String, addr:String) -> Bool{
        do{
            let sql = """
                insert into department(depart_title, depart_addr)
                values(?,?)
        """
            try self.fmdb.executeUpdate(sql, withArgumentsIn: [title, addr])
            return true
        }catch let error as NSError{
            print("삽입에러:\(error.localizedDescription)")
            return false
        }
    }
    
    //데이터를 삭제하는 메소드
    func remove(departCd: Int) -> Bool{
        do{
            let sql = """
                delete frome department
                where depart_cd = ?
        """
            try self.fmdb.executeUpdate(sql, withArgumentsIn: [departCd])
            return true
        }catch let error as NSError{
            print("삽입에러:\(error.localizedDescription)")
            return false
        }
    }
}
