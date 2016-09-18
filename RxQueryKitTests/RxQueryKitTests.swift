import XCTest
import CoreData
import QueryKit
import RxQueryKit


class RxQueryKitTests: XCTestCase {
  var context: NSManagedObjectContext!

  override func setUp() {
    let model = NSManagedObjectModel()
    model.entities = [Person.createEntityDescription(), Comment.createEntityDescription()]
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = persistentStoreCoordinator
  }

  // Make sure we've configure our store and model correctly
  func testCoreData() {
    let person = Person.create(context, name: "kyle")
    XCTAssertEqual(person.name, "kyle")
  }

  func testCount() {
    var counts: [Int] = []
    let queryset = Person.queryset(context)
    let disposable = try! queryset.count().subscribe(onNext: {
      counts.append($0)
    })

    // Initial value
    XCTAssertEqual(counts, [0])

    // Created
    let p1 = Person.create(context, name: "kyle1")
    _ = Person.create(context, name: "kyle2")
    let p3 = Person.create(context, name: "kyle3")
    try! context.save()
    XCTAssertEqual(counts, [0, 3])

    // Deleted
    context.delete(p1)
    context.delete(p3)
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1])

    // Doesn't update when nothing changes
    _ = Comment.create(context, text: "Hello World")
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1])

    disposable.dispose()
  }

  func testCountWithPredicate() {
    var counts: [Int] = []
    let disposable = try! Person.queryset(context)
      .filter { $0.name != "kyle" }
      .count()
      .subscribe(onNext: {
        counts.append($0)
      })

    // Initial value
    XCTAssertEqual(counts, [0])

    // Created
    let p1 = Person.create(context, name: "kyle1")
    _ = Person.create(context, name: "kyle2")
    let p3 = Person.create(context, name: "kyle3")
    let p4 = Person.create(context, name: "kyle")
    try! context.save()
    XCTAssertEqual(counts, [0, 3])

    // Deleted
    context.delete(p1)
    context.delete(p3)
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1])

    // Doesn't update when nothing changes
    _ = Comment.create(context, text: "Hello World")
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1])

    // Modify comes into count
    p4.name = "kyle4"
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1, 2])

    disposable.dispose()
  }

  func testObjects() {
    var objects: [[Person]] = []

    let disposable = try! Person.queryset(context)
      .orderBy { $0.name.ascending() }
      .objects()
      .subscribe(onNext: {
        objects.append($0)
      })

    // Initial value
    XCTAssertEqual(objects.count, 1)
    XCTAssertTrue(objects[0].isEmpty)

    // Created
    let p1 = Person.create(context, name: "kyle1")
    let p2 = Person.create(context, name: "kyle2")
    let p3 = Person.create(context, name: "kyle3")
    try! context.save()
    XCTAssertEqual(objects.count, 2)
    XCTAssertEqual(objects[1], [p1, p2, p3])

    // Deleted
    context.delete(p1)
    context.delete(p3)
    try! context.save()
    XCTAssertEqual(objects.count, 3)
    XCTAssertEqual(objects[2], [p2])

    // Modified Object
    context.delete(p1)
    context.delete(p3)
    p2.name = "kyle updated"
    try! context.save()
    XCTAssertEqual(objects.count, 4)
    XCTAssertEqual(objects[3], [p2])

    // Doesn't update when nothing changes
    _ = Comment.create(context, text: "Hello World")
    try! context.save()
    XCTAssertEqual(objects.count, 4)

    disposable.dispose()
  }
}


@objc(Person) class Person : NSManagedObject {
  class var name:Attribute<String> {
    return Attribute("name")
  }

  class func createEntityDescription() -> NSEntityDescription {
    let name = NSAttributeDescription()
    name.name = "name"
    name.attributeType = .stringAttributeType
    name.isOptional = false

    let entity = NSEntityDescription()
    entity.name = "Person"
    entity.managedObjectClassName = "Person"
    entity.properties = [name]
    return entity
  }

  class func queryset(_ context: NSManagedObjectContext) -> QuerySet<Person> {
    return QuerySet(context, "Person")
  }

  class func create(_ context: NSManagedObjectContext, name: String) -> Person {
    let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)!
    let person = Person(entity: entity, insertInto: context)
    person.name = name
    return person
  }

  @NSManaged var name: String
}

@objc(Comment) class Comment : NSManagedObject {
  class func createEntityDescription() -> NSEntityDescription {
    let text = NSAttributeDescription()
    text.name = "text"
    text.attributeType = .stringAttributeType
    text.isOptional = false

    let entity = NSEntityDescription()
    entity.name = "Comment"
    entity.managedObjectClassName = "Comment"
    entity.properties = [text]
    return entity
  }

  class func create(_ context: NSManagedObjectContext, text: String) -> Comment {
    let entity = NSEntityDescription.entity(forEntityName: "Comment", in: context)!
    let comment = Comment(entity: entity, insertInto: context)
    comment.text = text
    return comment
  }

  @NSManaged var text: String
}
