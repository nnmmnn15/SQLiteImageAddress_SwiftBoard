//
//  DatabaseManager.swift
//  iteImageAddress
//
//  Created by aeong on 12/18/24.
//

import Foundation
import SQLite3
import UIKit

class DatabaseManager {
    static let shared = DatabaseManager() // 싱글톤 인스턴스
    private let dbFileName = "addressBook.sqlite"
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTable()
    }

    // 1. 데이터베이스 열기 또는 생성
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbFileName)

        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("데이터베이스 열기 성공: \(fileURL.path)")
        } else {
            print("데이터베이스 열기 실패")
        }
    }

    // 2. 테이블 생성
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS AddressBook (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phoneNumber TEXT,
        address TEXT,
        relationship TEXT,
        image BLOB
        );
        """

        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("테이블 생성 성공")
            } else {
                print("테이블 생성 실패")
            }
        } else {
            print("테이블 생성 준비 실패")
        }
        sqlite3_finalize(createTableStatement)
    }

    // 3. 데이터 삽입 (INSERT)
    func insert(name: String, phoneNumber: String, address: String, relationship: String, image: UIImage?) {
        let insertQuery = "INSERT INTO AddressBook (name, phoneNumber, address, relationship, image) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (phoneNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (relationship as NSString).utf8String, -1, nil)

            // 이미지 데이터를 BLOB로 저장
            if let imageData = image?.pngData() {
                sqlite3_bind_blob(insertStatement, 5, (imageData as NSData).bytes, Int32(imageData.count), nil)
            } else {
                sqlite3_bind_null(insertStatement, 5)
            }

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("데이터 삽입 성공")
            } else {
                print("데이터 삽입 실패")
            }
        } else {
            print("INSERT 준비 실패")
        }
        sqlite3_finalize(insertStatement)
    }

    // 4. 데이터 조회 (SELECT)
    func fetchAll() -> [AddressBook] {
        let query = "SELECT * FROM AddressBook;"
        var queryStatement: OpaquePointer?

        var results: [AddressBook] = []

        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let phoneNumber = String(cString: sqlite3_column_text(queryStatement, 2))
                let address = String(cString: sqlite3_column_text(queryStatement, 3))
                let relationship = String(cString: sqlite3_column_text(queryStatement, 4))

                var image: UIImage? = nil
                if let imageBlob = sqlite3_column_blob(queryStatement, 5) {
                    let imageSize = sqlite3_column_bytes(queryStatement, 5)
                    let imageData = Data(bytes: imageBlob, count: Int(imageSize))
                    image = UIImage(data: imageData)
                }

                let record = AddressBook(id: Int(id), name: name, phoneNumber: phoneNumber, address: address, relationship: relationship, image: image)
                results.append(record)
            }
        } else {
            print("SELECT 준비 실패")
        }
        sqlite3_finalize(queryStatement)
        return results
    }

    // 5. 데이터 수정 (UPDATE)
    func update(id: Int, name: String, phoneNumber: String, address: String, relationship: String, image: UIImage?) {
        let updateQuery = "UPDATE AddressBook SET name = ?, phoneNumber = ?, address = ?, relationship = ?, image = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (phoneNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, (relationship as NSString).utf8String, -1, nil)

            if let imageData = image?.pngData() {
                sqlite3_bind_blob(updateStatement, 5, (imageData as NSData).bytes, Int32(imageData.count), nil)
            } else {
                sqlite3_bind_null(updateStatement, 5)
            }

            sqlite3_bind_int(updateStatement, 6, Int32(id))

            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("데이터 수정 성공")
            } else {
                print("데이터 수정 실패")
            }
        } else {
            print("UPDATE 준비 실패")
        }
        sqlite3_finalize(updateStatement)
    }

    // 6. 데이터 삭제 (DELETE)
    func delete(id: Int) {
        let deleteQuery = "DELETE FROM AddressBook WHERE id = ?;"
        var deleteStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))

            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("데이터 삭제 성공")
            } else {
                print("데이터 삭제 실패")
            }
        } else {
            print("DELETE 준비 실패")
        }
        sqlite3_finalize(deleteStatement)
    }
}
