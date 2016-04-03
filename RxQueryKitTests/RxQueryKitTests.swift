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
    try! persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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
    let disposable = try! queryset.count().subscribeNext {
      counts.append($0)
    }

    // Initial value
    XCTAssertEqual(counts, [0])

    // Created
    let p1 = Person.create(context, name: "kyle1")
    Person.create(context, name: "kyle2")
    let p3 = Person.create(context, name: "kyle3")
    try! context.save()
    XCTAssertEqual(counts, [0, 3])

    // Deleted
    context.deleteObject(p1)
    context.deleteObject(p3)
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1])

    // Doesn't update when nothing changes
    Comment.create(context, text: "Hello World")
    try! context.save()
    XCTAssertEqual(counts, [0, 3, 1])

    disposable.dispose()
  }

  func testObjects() {
    var objects: [[Person]] = []

    let disposable = try! Person.queryset(context)
      .orderBy { $0.name.ascending() }
      .objects()
      .subscribeNext {
        objects.append($0)
      }

    // Initial value
    XCTAssertEqual(objects, [[]])

    // Created
    let p1 = Person.create(context, name: "kyle1")
    let p2 = Person.create(context, name: "kyle2")
    let p3 = Person.create(context, name: "kyle3")
    try! context.save()
    XCTAssertEqual(objects, [[], [p1, p2, p3]])

    // Deleted
    context.deleteObject(p1)
    context.deleteObject(p3)
    try! context.save()
    XCTAssertEqual(objects, [[], [p1, p2, p3], [p2]])

    // Modified Object
    context.deleteObject(p1)
    context.deleteObject(p3)
    p2.name = "kyle updated"
    try! context.save()
    XCTAssertEqual(objects, [[], [p1, p2, p3], [p2], [p2]])

    // Doesn't update when nothing changes
    Comment.create(context, text: "Hello World")
    try! context.save()
    XCTAssertEqual(objects, [[], [p1, p2, p3], [p2], [p2]])

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
    name.attributeType = .StringAttributeType
    name.optional = false

    let entity = NSEntityDescription()
    entity.name = "Person"
    entity.managedObjectClassName = "Person"
    entity.properties = [name]
    return entity
  }

  class func queryset(context: NSManagedObjectContext) -> QuerySet<Person> {
    return QuerySet(context, "Person")
  }

  class func create(context: NSManagedObjectContext, name: String) -> Person {
    let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
    let person = Person(entity: entity, insertIntoManagedObjectContext: context)
    person.name = name
    return person
  }

  @NSManaged var name: String
}

@objc(Comment) class Comment : NSManagedObject {
  class func createEntityDescription() -> NSEntityDescription {
    let text = NSAttributeDescription()
    text.name = "text"
    text.attributeType = .StringAttributeType
    text.optional = false

    let entity = NSEntityDescription()
    entity.name = "Comment"
    entity.managedObjectClassName = "Comment"
    entity.properties = [text]
    return entity
  }

  class func create(context: NSManagedObjectContext, text: String) -> Comment {
    let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context)!
    let comment = Comment(entity: entity, insertIntoManagedObjectContext: context)
    comment.text = text
    return comment
  }

  @NSManaged var text: String
}