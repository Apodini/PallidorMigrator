# PallidorMigrator

<p align="center">
  <img width="150" src="https://github.com/Apodini/PallidorMigrator/blob/develop/Images/pallidor-icon.png">
</p>

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/Swift-5.3-blue.svg" alt="Swift 5.3">
    </a>
      <a href="https://github.com/Apodini/PallidorMigrator">
        <img src="https://github.com/Apodini/PallidorMigrator/workflows/Build%20and%20Test/badge.svg" alt="Build and Test">
    </a>
</p>

`PallidorMigrator` is a Swift package that generates a persistent facade layer for accessing a Web API dependency. Therefore, it incorporates all changes stated in a machine-readable migration guide into the internals of the facade. It is part of [**Pallidor**](https://github.com/Apodini/PallidorMigrator), a commandline tool which automatically migrates client applications after a Web API dependency changed.

## Requirements
This library requires at least Swift 5.3 and macOS 10.15.
## Integration
To integrate the `PallidorMigrator` library in your SwiftPM project, add the following line to the dependencies in your `Package.swift` file:
```swift
.package(url: "https://github.com/Apodini/PallidorMigrator.git", .branch("develop"))
```
Because `PallidorMigrator` is currently under active development, there is no guarantee for source-stability.

## Usage
To get started with `PallidorMigrator` you first need to create an instance of it, providing the path to the directory in which the source files are located, as well as the path to the location of the migration guide:
```swift
var targetPath : String = ...
var guidePath : String = ...
let migrator = try PallidorMigrator(targetDirectory: targetPath, migrationGuidePath: guidePath)
```
To start with generating the persistent facade, you call the `buildFacade()` method:
```swift
try migrator.buildFacade()
```
All generated facade files will be located under `{targetDirectory}/PersistentModels` or `{targetDirectory}/PersistentAPIs`

## Contributing
Contributions to this projects are welcome. Please make sure to read the [contribution guidelines](https://github.com/Apodini/.github/blob/release/CONTRIBUTING.md) first.

## License
This project is licensed under the MIT License. See [License](https://github.com/Apodini/Template-Repository/blob/release/LICENSE) for more information.
