import Foundation
import SourceryFramework
import SourceryRuntime
import PathKit

public struct PallidorMigrator {
    
    let decoder = JSONDecoder()
    
    var codeStore: CodeStore?
    var targetDirectory : Path
    var migrationGuide : MigrationGuide
    var migrationSet : MigrationSet
    
    public init(targetDirectory: String, migrationGuidePath: String? = nil, migrationGuideContent: String? = nil) throws {
        
        self.targetDirectory = Path(targetDirectory)
        
        if migrationGuidePath == nil, migrationGuideContent == nil {
            fatalError("must specify migrationGuidePath or content")
        }
        
        if self.targetDirectory.exists {
            self.codeStore = CodeStore.initInstance(targetDirectory: self.targetDirectory)
        }
        
        if let migrationGuidePath = migrationGuidePath {
            let content = try Data(contentsOf: URL(fileURLWithPath: migrationGuidePath))
            self.migrationGuide = try decoder.decode(MigrationGuide.self, from: content)
        } else {
            self.migrationGuide = try decoder.decode(MigrationGuide.self, from: migrationGuideContent!.data(using: .utf8)!)
        }
    
        self.migrationSet = self.migrationGuide.migrationSet
    }
    
    
    public func buildFacade() throws -> [URL] {
        
        guard let codeStore = self.codeStore else {
            fatalError("Code Store could not be initialized.")
        }
        
        var filePaths = [URL]()
        let modelDirectory = targetDirectory + Path("Models")
        let apiDirectory = targetDirectory + Path("APIs")
        
        let modelFacade = ModelFacade(modifiables: codeStore.getModels(), targetDirectory: modelDirectory, migrationSet: self.migrationSet)
        let enumFacade = EnumFacade(modifiables: codeStore.getEnums(), targetDirectory: modelDirectory, migrationSet: self.migrationSet)
        let apiFacade = APIFacade(modifiables: codeStore.getEndpoints(), targetDirectory: apiDirectory, migrationSet: self.migrationSet)
        let errorFacade = ErrorFacade(modifiables: codeStore.hasFacade ? [codeStore.getEnum("OpenAPIError", searchInCurrent: true)!, codeStore.getEnum("OpenAPIError")!] : [codeStore.getEnum("OpenAPIError", searchInCurrent: true)!], targetDirectory: targetDirectory)
        
        filePaths.append(contentsOf: try modelFacade.persist())
        filePaths.append(contentsOf: try apiFacade.persist())
        filePaths.append(contentsOf: try enumFacade.persist())
        filePaths.append(contentsOf: try errorFacade.persist())
              
        return filePaths
    }
}
