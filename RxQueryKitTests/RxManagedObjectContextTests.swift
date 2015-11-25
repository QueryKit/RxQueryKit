import XCTest
import RxSwift
import RxQueryKit

class RxManagedObjectContextTests: XCTestCase {
  let disposeBag = DisposeBag()

  func testObjectsDidChangeNotification() {
    let context = NSManagedObjectContext()

    let expectation = expectationWithDescription("Objects Did Change Notification")
    context.qk_objectsDidChange().subscribeNext { [unowned context] notification in
      XCTAssertEqual(notification.managedObjectContext, context)
      expectation.fulfill()
    }.addDisposableTo(disposeBag)

    NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextObjectsDidChangeNotification, object: context, userInfo: [:])
    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testWillSaveNotification() {
    let context = NSManagedObjectContext()

    let expectation = expectationWithDescription("Will Save Notification")
    context.qk_willSave().subscribeNext { [unowned context] managedObjectContext in
      XCTAssertEqual(managedObjectContext, context)
      expectation.fulfill()
    }.addDisposableTo(disposeBag)

    NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextWillSaveNotification, object: context, userInfo: [:])
    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testDidSaveNotification() {
    let context = NSManagedObjectContext()

    let expectation = expectationWithDescription("Did Save Notification")
    context.qk_didSave().subscribeNext { [unowned context] notification in
      XCTAssertEqual(notification.managedObjectContext, context)
      expectation.fulfill()
    }.addDisposableTo(disposeBag)

    NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextDidSaveNotification, object: context, userInfo: [:])
    waitForExpectationsWithTimeout(1.0, handler: nil)
  }
}
