//
//  DatabaseManager.swift
//  iteImageAddress
//
//  Created by aeong on 12/18/24.
//

import Foundation
import SQLite3

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
}
