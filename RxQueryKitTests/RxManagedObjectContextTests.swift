import XCTest
import RxQueryKit

class RxManagedObjectContextTests: XCTestCase {
  func testObjectsDidChangeNotification() {
    let context = NSManagedObjectContext()

    let expectation = expectationWithDescription("Objects Did Change Notification")
    let _ = context.qk_objectsDidChange().subscribeNext { [unowned context] notification in
      XCTAssertEqual(notification.managedObjectContext, context)
      expectation.fulfill()
    }

    NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextObjectsDidChangeNotification, object: context, userInfo: [:])
    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testWillSaveNotification() {
    let context = NSManagedObjectContext()

    let expectation = expectationWithDescription("Will Save Notification")
    let _ = context.qk_willSave().subscribeNext { [unowned context] managedObjectContext in
      XCTAssertEqual(managedObjectContext, context)
      expectation.fulfill()
    }

    NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextWillSaveNotification, object: context, userInfo: [:])
    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testDidSaveNotification() {
    let context = NSManagedObjectContext()

    let expectation = expectationWithDescription("Did Save Notification")
    let _ = context.qk_didSave().subscribeNext { [unowned context] notification in
      XCTAssertEqual(notification.managedObjectContext, context)
      expectation.fulfill()
    }

    NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextDidSaveNotification, object: context, userInfo: [:])
    waitForExpectationsWithTimeout(1.0, handler: nil)
  }
}
