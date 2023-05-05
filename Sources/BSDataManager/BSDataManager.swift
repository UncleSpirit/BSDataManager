import CoreData


public enum BSDataManagerError: Error {
    case failedToDetermineDefaultModel
    case modelDoesNotExist(String)
    case storeLoadingError(Error)
    case alreadyInitialized
    
    case savingError(Error)
    case fetchingError(Error)
    case templateLoadingError(String)
    
    case entityNotFound(String)
    case resultTypeNotDetermined
    case requestTypeMismatch(requested: NSPersistentStoreRequestType, expected: NSPersistentStoreRequestType)
    case requestedObjectTypeMismatch(requested: String, expected: String)
}


public final class BSDataManager {
    
    // MARK: - Static Private properties / methods
    
    static private var sharedInstanceInitialized: Bool = false
    static private weak var bundle: Bundle? = nil
    
    static private func modelExist(name: String, in bundle: Bundle?) -> Bool {
        guard !name.isEmpty else { return false }
        
        return (bundle ?? Bundle.main).url(forResource: name, withExtension: "momd") != nil
    }
    
    static private func resolvedModelName(from name: String, in bundle: Bundle?) -> String? {
        let charactersToReplace: Set<Character> = [" ", ",", ".", "-"]
        let underscore: Character = "_"
        let underscoreAsString = String(underscore)
        var name: String = name.map({ charactersToReplace.contains($0) ? underscoreAsString : String($0) }).joined()
        
        if modelExist(name: name, in: bundle) {
            return name
        }
        
        name.removeAll { $0 == underscore }
        
        return modelExist(name: name, in: bundle) ? name : nil
    }
    
    static private func getModelName(in bundle: Bundle?) -> String {
        let bundle = bundle ?? Bundle.main
        
        if let name = bundle.object(forInfoDictionaryKey: kCFBundleExecutableKey as String) as? String,
            let modelName = resolvedModelName(from: name, in: bundle) {
            return modelName
        }
        
        if let name = bundle.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String,
            let modelName = resolvedModelName(from: name, in: bundle) {
            return modelName
        }
        
        if let modelName = resolvedModelName(from: ProcessInfo.processInfo.processName, in: bundle) {
            return modelName
        }
        
//        fatalError("Failed to resolve data model name in bundle '\(bundle.name)'.")
        
        return ""
    }
    
    static private func checkRequestTypeCorrectness<T: NSFetchRequestResult>(request: NSFetchRequest<T>, requestType: NSPersistentStoreRequestType) throws {
        guard request.requestType == requestType else {
            throw BSDataManagerError.requestTypeMismatch(requested: request.requestType, expected: requestType)
        }
    }
    
    
    // MARK: - Shared singletone instance
    
    @NullResettable(defaultValue: getModelName(in: nil))
    static public private(set) var sharedModelName: String!
//    {
//        didSet {
//            print("sharedModelName didSet to '\(sharedModelName ?? "Default name (aka nil)")'")
//        }
//    }
    
    static public let shared: BSDataManager = {
        let instance: BSDataManager
        
        do {
            instance = try BSDataManager(modelName: sharedModelName, in: bundle ?? Bundle.main)
            
        } catch let error as BSDataManagerError {
            preconditionFailure("Failed to initialize shared data manager with error: \(type(of: error)).\(error)")
            
        } catch {
            preconditionFailure("Failed to initialize shared data manager with error: \(error.localizedDescription)")
        }
        
        bundle = nil
        sharedInstanceInitialized = true
        
        return instance
    }()
    
    
    static public func initializeShared(modelName: String? = nil, in bundle: Bundle? = nil) throws {
        
        guard !sharedInstanceInitialized else {
            throw BSDataManagerError.alreadyInitialized
        }
        
        if let modelName = modelName {
            guard modelExist(name: modelName, in: bundle) else {
                throw BSDataManagerError.modelDoesNotExist(modelName)
            }
            
            sharedModelName = modelName
            
        } else if let bundle = bundle {
            let resolvedName = getModelName(in: bundle)
            guard !resolvedName.isEmpty else {
                throw BSDataManagerError.failedToDetermineDefaultModel
            }
            
            sharedModelName = resolvedName
        }
        
        self.bundle = bundle
        
        _ = self.shared
    }
    
    
    // MARK: - Common static functionality
    
    @inlinable static public func entityName<T: NSManagedObject>(_ type: T.Type) -> String {
        return T.entity().name ?? ""
    }
    
    
    // MARK: - Fetch / Execute (Basic)
    
    static public func fetch<T>(request: NSFetchRequest<T>, context: NSManagedObjectContext) throws -> [T] {
        
        try checkRequestTypeCorrectness(request: request, requestType: .fetchRequestType)
        
        let result: [T]
        
        do {
            result = try context.fetch(request)
        } catch {
            throw BSDataManagerError.fetchingError(error)
        }
        
        return result
    }
    
    static public func execute<T>(request: NSFetchRequest<T>, context: NSManagedObjectContext) throws -> [T] {
        
        try checkRequestTypeCorrectness(request: request, requestType: .fetchRequestType)
        
        let result: [T]
        
        do {
            result = (try context.execute(request) as! NSAsynchronousFetchResult<T>).finalResult!
        } catch {
            throw BSDataManagerError.fetchingError(error)
        }
        
        return result
    }
    
    
    
    // MARK: - Instance properties
    
    public let modelName: String
    public let container: NSPersistentContainer
    public let initializedFromMainBundle: Bool
    public private(set) weak var bundle: Bundle? = nil
    
    
    // MARK: - Instance initialization
    
    public init(modelName: String, in bundle: Bundle) throws {
        guard type(of: self).modelExist(name: modelName, in: bundle) else {
            throw BSDataManagerError.modelDoesNotExist(modelName)
        }
        
        self.modelName = modelName
        
        initializedFromMainBundle = bundle.isMainBundle
        
        if !initializedFromMainBundle {
            self.bundle = bundle
        }
        
        if !initializedFromMainBundle,
            let url = bundle.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url) {
            container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: modelName)
        }
        
        var loadingError: BSDataManagerError? = nil
        
        container.loadPersistentStores { description, error in
            if let error = error {
                loadingError = .storeLoadingError(error)
                return
            }
        }
        
        if let loadingError = loadingError {
            throw loadingError
        }
    }
    
    public convenience init?(modelName: String, in bundle: Bundle? = nil) {
        do {
            try self.init(modelName: modelName, in: bundle ?? Bundle.main)
        } catch {
            return nil
        }
    }
    
    
    // MARK: - Private functions
    
    private func getClass(entity: NSEntityDescription) throws -> AnyClass {
        guard let obtainedClass = (initializedFromMainBundle ? Bundle.main : bundle)?.classNamed(entity.managedObjectClassName) else {
            throw BSDataManagerError.resultTypeNotDetermined
        }
        
        return obtainedClass
    }
    
    private func checkCorrectness<U: NSFetchRequestResult>(entity: NSEntityDescription, for resultType: U.Type) throws {
        
        guard U.self is NSManagedObject.Type else { return }
        
        let obtainedClass: AnyClass = try getClass(entity: entity)
        
        guard obtainedClass == U.self else {
            throw BSDataManagerError.requestedObjectTypeMismatch(requested: String(describing: U.self), expected: String(describing: obtainedClass))
        }
    }
    
    private func checkCorrectness<T: NSFetchRequestResult, U: NSFetchRequestResult>(request: NSFetchRequest<T>, for resultType: U.Type) throws {
        guard let entity = request.entity else {
            throw BSDataManagerError.resultTypeNotDetermined
        }
        
        let isCorrect: Bool
        let expectedType: AnyClass
        
        switch request.resultType {
        case .managedObjectResultType:
            expectedType = try getClass(entity: entity)
            isCorrect = expectedType == U.self // U.self is NSManagedObject.Type
            
        case .managedObjectIDResultType:
            isCorrect = U.self is NSManagedObjectID.Type
            expectedType = NSManagedObjectID.self
            
        case .dictionaryResultType:
            isCorrect = U.self is NSDictionary.Type
            expectedType = NSDictionary.self
            
        case .countResultType:
            isCorrect = U.self is NSNumber.Type
            expectedType = NSNumber.self
            
        default:
            isCorrect = false
            expectedType = NSManagedObject.self
        }
        
        guard isCorrect else {
            throw BSDataManagerError.requestedObjectTypeMismatch(requested: String(describing: U.self), expected: String(describing: expectedType))
        }
    }
    
    
    // MARK: - Common functions
    
    public func saveChanges(of context: NSManagedObjectContext? = nil) throws {
        let currentContext = context ?? container.viewContext
        
        if currentContext.hasChanges {
            do {
                try currentContext.save()
            } catch {
                throw BSDataManagerError.savingError(error)
            }
        }
        
        while let parentContext = currentContext.parent {
            try saveChanges(of: parentContext)
        }
    }
    
    public func entity(named: String, in context: NSManagedObjectContext?) throws -> NSEntityDescription {
        let currentContext = context ?? container.viewContext
        
        guard !named.isEmpty, let entity = NSEntityDescription.entity(forEntityName: named, in: currentContext) else {
            throw BSDataManagerError.entityNotFound(named)
        }
        
        return entity
    }
    
    
    // MARK: - Requests
    
    public func request<U: NSFetchRequestResult>(
        entity: NSEntityDescription,
        asFaults: Bool = true,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> NSFetchRequest<U> {
        
        try checkCorrectness(entity: entity, for: U.self)
        
        let request = NSFetchRequest<U>()
        request.entity = entity
        
        let resultType: NSFetchRequestResultType
        
        switch U.self {
        case is NSManagedObject.Type:
            resultType = .managedObjectResultType
            
        case is NSManagedObjectID.Type:
            resultType = .managedObjectIDResultType
            request.includesPropertyValues = false
            
        case is NSDictionary.Type:
            resultType = .dictionaryResultType
            request.propertiesToFetch = fields
            request.propertiesToGroupBy = groupBy
            request.havingPredicate = havingPredicate
            
        case is NSNumber.Type:
            resultType = .countResultType
            request.includesPropertyValues = false
            
        default:
            resultType = .managedObjectResultType
        }
        
        if request.resultType != resultType {
            request.resultType = resultType
        }
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.returnsObjectsAsFaults = asFaults
        request.returnsDistinctResults = distinctResults
        
        return request
    }
    
    public func request<U: NSFetchRequestResult>(
        entityName: String,
        asFaults: Bool = true,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> NSFetchRequest<U> {
        let entity = try entity(named: entityName, in: context)
        
        return try request(entity: entity, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
    }
    
    public func request<T: NSManagedObject, U: NSFetchRequestResult>(
        forType: T.Type,
        asFaults: Bool = true,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> NSFetchRequest<U> {
        return try request(entity: forType.entity(), asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
    }
    
    
    // MARK: - Requests from templates
    
    public func request<U: NSFetchRequestResult>(templateName: String, substitutionVariables: [String : Any]?) throws -> NSFetchRequest<U> {
        let result: NSFetchRequest<NSFetchRequestResult>
        
        if let substitutionVariables = substitutionVariables, !substitutionVariables.isEmpty {
            guard let templateRequest = container.managedObjectModel.fetchRequestFromTemplate(withName: templateName, substitutionVariables: substitutionVariables) else {
                throw BSDataManagerError.templateLoadingError(templateName)
            }
            result = templateRequest
            
        } else {
            guard let templateRequest = container.managedObjectModel.fetchRequestTemplate(forName: templateName) else {
                throw BSDataManagerError.templateLoadingError(templateName)
            }
            result = templateRequest
        }
        
        try checkCorrectness(request: result, for: U.self)
        return result as! NSFetchRequest<U>
    }
    
    
    // MARK: - Record creation
    
    public func newRecord<T: NSManagedObject>(in context: NSManagedObjectContext? = nil) -> T {
        return T(context: context ?? container.viewContext)
        
//        return NSEntityDescription.insertNewObject(forEntityName: BSDataManager.entityName(T.self), into: context ?? container.viewContext) as! T
    }
    
    public func newRecord<T: NSManagedObject>(keyedValues: [String : Any], in context: NSManagedObjectContext? = nil) -> T {
        let obj: T = newRecord(in: context)
        
        guard !keyedValues.isEmpty else {
            return obj
        }
        
        obj.setValuesForKeys(keyedValues)
        return obj
    }
    
    
    // MARK: - Record deletion
    
    public func deleteRecord<T: NSManagedObject>(_ object: T) {
        container.viewContext.delete(object)
    }
    
}
