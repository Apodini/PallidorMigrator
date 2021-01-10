//
//  File.swift
//  
//
//  Created by Andre Weinkoetz on 04.01.21.
//

import Foundation

extension WrappedMethod {
    func mapStringPrimitiveTypes(_ change: ReplaceChange) -> (String) -> String {
        { type in
            type.isArrayType ?
            """
            .map({ (result) -> \(type) in
                let context = JSContext()!
                context.evaluateScript(\"""\n\(
                    // must provide revert method due to migration guide constraints
                    // for ReplaceChanges.
                    // swiftlint:disable:next force_unwrapping
                    change.customRevert!)\n\""")
                let encString = context
                            .objectForKeyedSubscript("conversion")
                            .call(withArguments: [String(result)])?.toString()
                return (try! JSONDecoder().decode(
                                    \(type.replacingOccurrences(of: "[", with: "[_")).self,
                                    from: encString!.data(using: .utf8)!))
                                .map({\(type.itemType)($0)!})
            })
            """ :
            """
            .map({ (result) -> \(type) in
                let context = JSContext()!
                context.evaluateScript(\"""\n\(
                    // must provide revert method due to migration guide constraints
                    // for ReplaceChanges.
                    // swiftlint:disable:next force_unwrapping
                    change.customRevert!)\n\""")
                let encString = context
                            .objectForKeyedSubscript("conversion")
                            .call(withArguments: [String(result)])?.toString()
                return \(type)(try! JSONDecoder().decode(_\(type).self, from: encString!.data(using: .utf8)!))!
            })
            """
        }
    }

    func mapStringComplexTypes(_ change: ReplaceChange) -> (String) -> String {
        { type in
        let defaultEncoding = """
        .map({ (result) -> \(type) in
            let context = JSContext()!
            let encoded = try! JSONEncoder().encode(result)
            context.evaluateScript(\"""\n\(
                // must provide revert method due to migration guide constraints
                // for ReplaceChanges.
                // swiftlint:disable:next force_unwrapping
                change.customRevert!)\n\""")
            let encString = context
                    .objectForKeyedSubscript("conversion")
                    .call(withArguments: [String(data: encoded, encoding: .utf8)!])?.toString()
        """

        return  !type.isPrimitiveType ? (type.isArrayType ?
        """
        \(defaultEncoding)
            return (try! JSONDecoder()
                        .decode(
                                \(type.replacingOccurrences(of: "[", with: "[_")).self,
                                from: encString!.data(using: .utf8)!))
                        .map({\(type.itemType)($0)!})
        })
        """ :
        """
        \(defaultEncoding)
            return \(type)(try! JSONDecoder().decode(_\(type).self, from: encString!.data(using: .utf8)!))!
        })
        """)
        :
        """
        \(defaultEncoding)
            \(type.isCollectionType
            ? "return \(type)(try! JSONDecoder().decode(\(type).self, from: encString!.data(using: .utf8)!))!"
            : "return encString!" // "return \(type.upperFirst)(encString)!"
            )
        })
        """
        }
    }
}
