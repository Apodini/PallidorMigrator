//
//  Enum+CompareCases.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedEnum {
    /// Compares the cases between to enums
    /// so that differences can be detected and the
    /// corresponding change types can be created.
    /// - Parameter rhs: comparing enum
    /// - Returns: list of changes
    func compareCases(_ rhs: WrappedEnum) -> [Change] {
        let addChange = compareAddedCases(rhs)
        let delChanges = compareDeletedCases(rhs)
        var changes = [Change]()
        changes.append(addChange)
        changes.append(contentsOf: delChanges)
        return changes
    }

    /// Checks for added cases
    /// - Parameter rhs: comparing enum
    /// - Returns: AddChange
    private func compareAddedCases(_ rhs: WrappedEnum) -> Change {
        var cases = [EnumModel.Case]()

        for targetCase in self.cases {
            if !rhs.cases.contains(where: { $0.name == targetCase.name }) {
                cases.append(EnumModel.Case(case: targetCase.name))
            }
        }
        let eModel = EnumModel(
            enumName: self.localName.replacingOccurrences(of: "_", with: ""),
            cases: cases
        )
        return AddChange(
            added: cases,
            reason: "Added new cases",
            object: .enum(eModel),
            target: .case
        )
    }

    /// Checks for deleted cases
    /// - Parameter rhs: comparing enum
    /// - Returns: DeleteChange
    private func compareDeletedCases(_ rhs: WrappedEnum) -> [Change] {
        let delChange = rhs.compareAddedCases(self)
        if case let .enum(model) = delChange.object {
            return model.cases.map {
                                    DeleteChange(
                                        fallbackValue: $0,
                                        reason: "Deleted case",
                                        object: .enum(model),
                                        target: .case)
            }
        }
        return []
    }
}
