import XCTest
import RxSwift
import RxQueryKit

class RxManagedObjectContextTests: XCTestCase {
  let disposeBag = DisposeBag()

  func testObjectsDidChangeNotification() {
    let context = NSManagedObjectContext()

    let expectation = self.expectation(description: "Objects Did Change Notification")
    context.qk_objectsDidChange().subscribe(onNext: { [unowned context] notification in
      XCTAssertEqual(notification.managedObjectContext, context)
      expectation.fulfill()
    }).disposed(by: disposeBag)

    NotificationCenter.default.post(name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, userInfo: [:])
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testWillSaveNotification() {
    let context = NSManagedObjectContext()

    let expectation = self.expectation(description: "Will Save Notification")
    context.qk_willSave().subscribe(onNext: { [unowned context] managedObjectContext in
      XCTAssertEqual(managedObjectContext, context)
      expectation.fulfill()
    }).disposed(by: disposeBag)

    NotificationCenter.default.post(name: NSNotification.Name.NSManagedObjectContextWillSave, object: context, userInfo: [:])
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testDidSaveNotification() {
    let context = NSManagedObjectContext()

    let expectation = self.expectation(description: "Did Save Notification")
    context.qk_didSave().subscribe(onNext: { [unowned context] notification in
      XCTAssertEqual(notification.managedObjectContext, context)
      expectation.fulfill()
    }).disposed(by: disposeBag)

    NotificationCenter.default.post(name: NSNotification.Name.NSManagedObjectContextDidSave, object: context, userInfo: [:])
    waitForExpectations(timeout: 1.0, handler: nil)
  }
}
