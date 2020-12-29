#  Multi-Version Migration
Pallidor is able to migrate the generated client library between two versions of a Web API. Since Web APIs evolve over time across multiple versions, each of which introduces its own changes, migration guides must be provided for migrating from each previous version to each subsequent version. Creating and maintaining a migration guide for each possible combination of versions is cumbersome and should therefore be automated.

This document provides a brief overview of an examplatory approach to combine multiple migration guides of various versions into a single migration guide for migrating from a specific version to the latest version available. In order to assign changes to the version in which they occured, each migration guide specifies a `from-version` and `to-version` property that contains the [semantic version](https://semver.org/) of the Web API. The example is centered around the migration of changes targeting methods of a Web API. 

## Adding & Removing Methods Over Time

Adding a method is a non-breaking change that introduces new functionality to the generated client library. They are not listed as a change in the migration guide and are automatically integrated in the library and facade layer. New methods can be added over time without requiring a specialized approach to combine them. Removing a method from the Web API without providing a replacement breaks the APIs contract. Since this is a non-migratable change, removing methods represent a final state that obsoletes previous changes and does not allow subsequent changes. In case the original method was replaced or renamed in the meantime, previous changes must be analyzed to target the correct identifier of the removed method:

```
// MIGRATION GUIDE v0.0.1 -> v0.0.2
{
    ...
    "from-version" : "0.0.1", // first version that was integrated using Pallidor
    "to-version" : "0.0.2",
    "changes" : [
        {
            "reason": "Renamed addPet() to addMyPet()",
            "object" : {
                "operation-id" : "addMyPet",
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "original-id" : "addPet"
        }
    ]

}

// MIGRATION GUIDE v0.0.2 -> v0.0.3
{
    ...
    "from-version" : "0.0.2",   // In the previous version the method was renamed.
    "to-version" : "0.0.3",     // In the current version, it is replaced by another method.
    "changes" : [
        {
            "reason": "replaced addMyPet() with addMyPetv2()",
            "object":{
               "operation-id":"addMyPetv2",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "addMyPetv2",
            "custom-convert" : "...",
            "custom-revert" : "...",
            "replaced" : {
               "operation-id":"addMyPet",
               "defined-in":"/pet"
             }
        }
    ]

}

// MIGRATION GUIDE v0.0.3 -> v0.0.4
{
    ...
    "from-version" : "0.0.3",   // In the previous version the original method was replaced by another method.
    "to-version" : "0.0.4",     // In the current version, this method is removed without a replacement.
    "changes" : [
        {
            "object" : {
                "operation-id" : "addMyPetv2",
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "fallback-value" : { }
        }
    ]

}
```
Combining these migration guides is performed by analyzing the changes of the intermediate versions. Tracing back all changes to the original method results in the adaption of the `object` property of the **RemoveChange**:

```
// MIGRATION GUIDE v0.0.1 -> v0.0.4
{
    ...
    "from-version" : "0.0.1",   // first version that was integrated using Pallidor
    "to-version" : "0.0.4",     // In the current version, the method is removed.
    "changes" : [
        {
            "object" : {
                "operation-id" : "addPet", // by tracing back, the original identifier can be identified and used here.
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "fallback-value" : { }
        }
    ]

}
```
## Renaming Methods Over Time

Renaming a method changes the identifier and thus breaking the APIs contract. After renaming a method, subsequent versions might further modify the renamed methods parameters or return values. Furthermore, its identifier can be changed again. All of these changes must be specified in a migration guide and can be combined by using the latest identifier of the method:

```
// MIGRATION GUIDE v0.0.1 -> v0.0.2
{
    ...
    "from-version" : "0.0.1", // first version that was integrated using Pallidor
    "to-version" : "0.0.2",
    "changes" : [
        {
            "reason": "Renamed addPet() to addMyPet()",
            "object" : {
                "operation-id" : "addMyPet",
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "original-id" : "addPet"
        }
    ]

}

// MIGRATION GUIDE v0.0.2 -> v0.0.3
{
    ...
    "from-version" : "0.0.2",   // In the previous version the method was renamed.
    "to-version" : "0.0.3",     // In the current version, it got a new parameter and replaced its return value.
    "changes" : [
        {
            "reason": "Added a new parameter 'status' to addMyPet()",
            "object" : {
                "operation-id" : "addMyPet", // uses new identifier 
                "defined-in" : "/pet"
            },
            "target" : "Parameter",
            "added" : [
                {
                    "name" : "status",
                    "type" : "String",
                    "default-value" : "available"
                }
            ]
        },
        {
           "reason": "Added a new parameter 'status' to addMyPet()",
           "object":{
              "operation-id": "addMyPet", // uses new identifier 
              "defined-in": "/pet"
           },
           "target": "ReturnValue",
           "replacement-id": "_",
           "type": "Order",
           "custom-revert": "...",
           "replaced":{
              "name":"_",
              "type":"Pet"
           }
        }
    ]

}

// MIGRATION GUIDE v0.0.3 -> v0.0.4
{
    ...
    "from-version" : "0.0.3",   // In the previous version the renamed methods parameters and return value were changed.
    "to-version" : "0.0.4",     // In the current version, this method is renamed again.
    "changes" : [
        {
            "reason": "Renamed addMyPet() to addMyPetv2()",
            "object" : {
                "operation-id" : "addMyPetv2",
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "original-id" : "addMyPet"
        }
    ]

}
```
In contrast to **RemoveChanges**, chaining the renaming of a method over time needs to take the intermediate changes into account when merging the migration guides. All changes that occured in between the renaming changes must use the latest identifier of the method, while the **RenameChange** needs to target the original identifier:

```
// MIGRATION GUIDE v0.0.1 -> v0.0.4
{
    ...
    "from-version" : "0.0.1",   // first version that was integrated using Pallidor
    "to-version" : "0.0.4",     // In the current version, the method is removed.
    "changes" : [
        {
            "reason": "Added a new parameter 'status' to addMyPet()",
            "object" : {
                "operation-id" : "addMyPetv2", // uses the latest identifier 
                "defined-in" : "/pet"
            },
            "target" : "Parameter",
            "added" : [
                {
                    "name" : "status",
                    "type" : "String",
                    "default-value" : "available"
                }
            ]
        },
        {
           "reason": "Replaced return type of addMyPet()",
           "object":{
              "operation-id": "addMyPetv2", // uses the latest identifier 
              "defined-in": "/pet"
           },
           "target": "ReturnValue",
           "replacement-id": "_",
           "type": "Order",
           "custom-revert": "...",
           "replaced":{
              "name":"_",
              "type":"Pet"
           }
        },
        {
            "reason": "Renamed addMyPet() to addMyPetv2()",
            "object" : {
                "operation-id" : "addMyPetv2",
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "original-id" : "addPet" // uses the original identifier 
        }
    ]

}
```
## Replacing Methods Over Time

Replacing methods differs from the previous change types in that they represent a reset of all previous change types except **RemoveChanges**. Chaining them over time requires to adapt identifiers along with the `custom-convert` and `custom-revert` algorithms. 

```
// MIGRATION GUIDE v0.0.1 -> v0.0.2
{
    ...
    "from-version" : "0.0.1", // first version that was integrated using Pallidor
    "to-version" : "0.0.2",
    "changes" : [
        {
            "object":{
               "operation-id":"addPetWithForm",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "addPetWithForm",
            "custom-convert" : "function conversion(o) { ... }", // converts parameters to fit parameters of new method
            "custom-revert" : "function conversion(o) { ... }", // reverts return value of new method to fit original return type
            "replaced" : {
               "operation-id":"addPet",
               "defined-in":"/pet"
             }
        }
    ]

}

// MIGRATION GUIDE v0.0.2 -> v0.0.3
{
    ...
    "from-version" : "0.0.2",   // In the previous version the method was replaced.
    "to-version" : "0.0.3",     // In the current version, it's renamed, got a new parameter, and replaced its return value.
    "changes" : [
        {
            "reason": "Added a new parameter 'status' to addPetWithMyForm()",
            "object" : {
                "operation-id" : "addPetWithMyForm", // targets renamed replacement method
                "defined-in" : "/pet"
            },
            "target" : "Parameter",
            "added" : [
                {
                    "name" : "status",
                    "type" : "String",
                    "default-value" : "available"
                }
            ]
        },
        {
           "reason": "Replaced return type of addPetWithMyForm()",
           "object":{
              "operation-id": "addPetWithMyForm", // targets renamed replacement method
              "defined-in": "/pet"
           },
           "target": "ReturnValue",
           "replacement-id": "_",
           "type": "Order",
           "custom-revert": "...",
           "replaced":{
              "name":"_",
              "type":"Pet"
           }
        },
        {
            "reason": "Renamed addPetWithMyForm() to addPetWithMyForm()",
            "object" : {
                "operation-id" : "addPetWithMyForm",
                "defined-in" : "/pet"
            },
            "target" : "Signature",
            "original-id" : "addPetWithForm" // uses identifier of replacement method
        }
    ]

}

// MIGRATION GUIDE v0.0.3 -> v0.0.4
{
    ...
    "from-version" : "0.0.3",   // In the previous version the replaced method was renamed and its parameters & return value were changed.
    "to-version" : "0.0.4",     // In the current version, this method is replaced by another method.
    "changes" : [
        {
            "object":{
               "operation-id":"addPetWithMyFormv2",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "addPetWithMyFormv2",
            "custom-convert" : "function conversion(o) { ... }", // specifies new convert algorithm
            "custom-revert" : "function conversion(o) { ... }", // specified new revert algorithm
            "replaced" : {
               "operation-id":"addPetWithMyForm",
               "defined-in":"/pet"
             }
        }
    ]

}
```

Since replacing a method resets it to the functionality of its latest replacement, only the latest replacement needs to be specified in the migration guide. However, intermediate changes need to be taken into account to determine the original identifier of the method. Changes that target a replaced method must be considered if they are not followed by another replacement:

```
// MIGRATION GUIDE v0.0.1 -> v0.0.3
// This migration guide does not contain the second replacement, hence the changes of version 0.0.3 must be taken into account when specifying the convert/revert algorithms.
{
    ...
    "from-version" : "0.0.1", // first version that was integrated using Pallidor
    "to-version" : "0.0.3", // target version
    "changes" : [
        {
            "object":{
               "operation-id":"addPetWithMyForm", // uses the renamed identifier of the replacement method
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "addPetWithMyForm",
            "custom-convert" : "function conversion(o) { ... }", // contains added parameter
            "custom-revert" : "function conversion(o) { ... }", // reverts from replaced return value
            "replaced" : {
               "operation-id":"addPet", // uses original identifier
               "defined-in":"/pet"
             }
        }
    ]

}

// MIGRATION GUIDE v0.0.1 -> v0.0.4
// This migration guide contains the second replacement and only needs to provide convert/revert algorithms for the latest replacement.
{
    ...
    "from-version" : "0.0.1", // first version that was integrated using Pallidor
    "to-version" : "0.0.4",   // target version
    "changes" : [
        {
            "object":{
               "operation-id":"addPetWithMyFormv2", // uses identifier of latest replacement
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "addPetWithMyFormv2",
            "custom-convert" : "function conversion(o) { ... }", // does not contains added parameter of v0.0.3
            "custom-revert" : "function conversion(o) { ... }", // does not reverts from return type of v0.0.3
            "replaced" : {
               "operation-id":"addPet", // uses original identifier
               "defined-in":"/pet"
             }
        }
    ]

}

```

## Future Work
Further investigations must be conducted to merge migration guides that contain the **M-N replacements of methods** change type (described in [here](https://github.com/Apodini/PallidorMigrator/blob/develop/ProposedTests/MethodMNReplaceTest.md)) and **implicit replacements** such as removing a method and adding a new method afterwards that provides a replacement for the previously removed method.

