// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PallidorMigrator",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PallidorMigrator",
            targets: ["PallidorMigrator"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/krzysztofzablocki/Sourcery", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PallidorMigrator",
            dependencies: [
                .product(name: "SourceryFramework", package: "Sourcery")
            ]),
        .testTarget(
            name: "PallidorMigratorTests",
            dependencies: ["PallidorMigrator",
                           .product(name: "SourceryFramework", package: "Sourcery")],
            resources: [
                .process("Resources/Endpoints/Input/EndpointPlaceholder.md"),
                .process("Resources/Endpoints/Input/PetEndpoint.md"),
                .process("Resources/Endpoints/Input/PetEndpointAddedContentBody.md"),
                .process("Resources/Endpoints/Input/PetEndpointAddedParameter.md"),
                .process("Resources/Endpoints/Input/PetEndpointDeletedMethod.md"),
                .process("Resources/Endpoints/Input/PetEndpointFacade.md"),
                .process("Resources/Endpoints/Input/PetEndpointFacadeDeletedMethod.md"),
                .process("Resources/Endpoints/Input/PetEndpointFacadeReplacedMethod.md"),
                .process("Resources/Endpoints/Input/PetEndpointRenamed.md"),
                .process("Resources/Endpoints/Input/PetEndpointRenamedParameter.md"),
                .process("Resources/Endpoints/Input/PetEndpointRenamedMethod.md"),
                .process("Resources/Endpoints/Input/PetEndpointRenamedMethodAndContentBody.md"),
                .process("Resources/Endpoints/Input/PetEndpointReplacedMethod.md"),
                .process("Resources/Endpoints/Input/PetEndpointReplacedParameter.md"),
                .process("Resources/Endpoints/Input/PetEndpointReplacedReturnValue.md"),
                .process("Resources/Endpoints/Input/StoreEndpointReplaceContentBody.md"),
                .process("Resources/Endpoints/Input/UserEndpointDeletedParameter.md"),
                .process("Resources/Endpoints/Input/UserEndpointReplacedMethod.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeAddedContentBody.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeAddedParameter.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeDeleted.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeDeletedMethod.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeRenamed.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeRenamedMethod.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeRenamedMethodAndContentBody.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeRenamedParameter.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeReplacedMethod.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeReplacedParameter.md"),
                .process("Resources/Endpoints/Results/ResultPetEndpointFacadeReplacedReturnValue.md"),
                .process("Resources/Endpoints/Results/ResultStoreEndpointFacadeReplacedContentBody.md"),
                .process("Resources/Endpoints/Results/ResultUserEndpointFacadeDeletedParameter.md"),
                .process("Resources/Models/Input/ModelPlaceholder.md"),
                .process("Resources/Models/Input/ModelAddress.md"),
                .process("Resources/Models/Input/ModelAddressRenamed.md"),
                .process("Resources/Models/Input/ModelApiResponseFacadeDeleted.md"),
                .process("Resources/Models/Input/ModelCategoryRenamedProperty.md"),
                .process("Resources/Models/Input/ModelCustomerReplacedProperty.md"),
                .process("Resources/Models/Input/ModelOfType.md"),
                .process("Resources/Models/Input/ModelOfTypeFacade.md"),
                .process("Resources/Models/Input/ModelOfTypeRenamed.md"),
                .process("Resources/Models/Input/ModelOrderFacadeReplaced.md"),
                .process("Resources/Models/Input/ModelPet.md"),
                .process("Resources/Models/Input/ModelPetRenamedProperty.md"),
                .process("Resources/Models/Results/ResultModelAddressRenamed.md"),
                .process("Resources/Models/Results/ResultModelApiResponseDeleted.md"),
                .process("Resources/Models/Results/ResultModelCategoryRenamedProperty.md"),
                .process("Resources/Models/Results/ResultModelCustomerReplacedProperty.md"),
                .process("Resources/Models/Results/ResultModelOfType.md"),
                .process("Resources/Models/Results/ResultModelOfTypeDeleted.md"),
                .process("Resources/Models/Results/ResultModelOfTypeDeletedCase.md"),
                .process("Resources/Models/Results/ResultModelOfTypeRenamed.md"),
                .process("Resources/Models/Results/ResultModelOfTypeReplaced.md"),
                .process("Resources/Models/Results/ResultModelOrderReplaced.md"),
                .process("Resources/Models/Results/ResultModelPet.md"),
                .process("Resources/Models/Results/ResultModelPetAddedComplexProperty.md"),
                .process("Resources/Models/Results/ResultModelAddressAddedSimpleProperty.md"),
                .process("Resources/Models/Results/ResultModelPetDeletedProperty.md"),
                .process("Resources/Models/Results/ResultModelPetRenamedProperty.md"),
                .process("Resources/Enums/Input/EnumMessageLevelFacade.md"),
                .process("Resources/Enums/Input/EnumPlaceholder.md"),
                .process("Resources/Enums/Input/EnumTimeMode.md"),
                .process("Resources/Enums/Input/EnumTimeModeFacade.md"),
                .process("Resources/Enums/Input/EnumTimeModeDeletedCase.md"),
                .process("Resources/Enums/Input/EnumTimeModeRenamed.md"),
                .process("Resources/Enums/Input/ErrorEnum.md"),
                .process("Resources/Enums/Input/ErrorEnumAddedCase.md"),
                .process("Resources/Enums/Input/ErrorEnumDeletedCase.md"),
                .process("Resources/Enums/Input/ErrorEnumFacadeAddedCase.md"),
                .process("Resources/Enums/Input/ErrorEnumFacadeDeletedCase.md"),
                .process("Resources/Enums/Results/ResultEnumMessageLevelReplaced.md"),
                .process("Resources/Enums/Results/ResultEnumTimeMode.md"),
                .process("Resources/Enums/Results/ResultEnumTimeModeDeleted.md"),
                .process("Resources/Enums/Results/ResultEnumTimeModeDeletedCase.md"),
                .process("Resources/Enums/Results/ResultEnumTimeModeRenamed.md"),
                .process("Resources/Enums/Results/ResultErrorEnum.md"),
                .process("Resources/Enums/Results/ResultErrorEnumAddedCase.md"),
                .process("Resources/Enums/Results/ResultErrorEnumDeletedCase.md")
            ]
        )
    ]
)
