import XCTest
import GRDB

class FetchableParent : DatabaseValueConvertible, CustomStringConvertible {
    var databaseValue: DatabaseValue {
        return DatabaseValue(string: "Parent")
    }
    
    class func fromDatabaseValue(databaseValue: DatabaseValue) -> Self? {
        return self.init()
    }
    
    // TODO: this implementation is mandatory to avoid a Swift compiler error.
    // Either avoid it, or document it.
    class func fromRow(row: Row) -> Self {
        // TODO: nice fatal error in case of error
        return fromDatabaseValue(row.databaseValues.first!)!
    }
    
    required init() {
    }
    
    var description: String { return "Parent" }
}

class FetchableChild : FetchableParent {
    /// Returns a value that can be stored in the database.
    override var databaseValue: DatabaseValue {
        return DatabaseValue(string: "Child")
    }
    
    override var description: String { return "Child" }
}

class DatabaseValueConvertibleSubclassTests: GRDBTestCase {
    
    func testParent() {
        assertNoError {
            try dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE parents (name TEXT)")
                try db.execute("INSERT INTO parents (name) VALUES (?)", arguments: [FetchableParent()])
                let string = String.fetchOne(db, "SELECT * FROM parents")!
                XCTAssertEqual(string, "Parent")
                let parent = FetchableParent.fetchOne(db, "SELECT * FROM parents")!
                XCTAssertEqual(parent.description, "Parent")
                let parents = FetchableParent.fetchAll(db, "SELECT * FROM parents")
                XCTAssertEqual(parents.first!.description, "Parent")
            }
        }
    }
    
    func testChild() {
        assertNoError {
            try dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE children (name TEXT)")
                try db.execute("INSERT INTO children (name) VALUES (?)", arguments: [FetchableChild()])
                let string = String.fetchOne(db, "SELECT * FROM children")!
                XCTAssertEqual(string, "Child")
                let child = FetchableChild.fetchOne(db, "SELECT * FROM children")!
                XCTAssertEqual(child.description, "Child")
                let children = FetchableChild.fetchAll(db, "SELECT * FROM children")
                XCTAssertEqual(children.first!.description, "Child")
            }
        }
    }
}
