import Foundation
import ApolloCodegenLib
import ArgumentParser

struct GraphQLTool: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
            abstract: """
        A swift-based utility for performing Apollo-related tasks.
        
        NOTE: If running from a compiled binary, prefix subcommands with `graph-ql-tool`. Otherwise use `swift run ApolloCodegen [subcommand]`.
        """,
            subcommands: [DownloadSchema.self, GenerateCode.self, DownloadSchemaAndGenerateCode.self])
    
    /// The sub-command to download a schema from a provided endpoint.
    struct DownloadSchema: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "download-schema",
            abstract: "Downloads the GraphQL schema"
        )

        @Argument(help: "the environment to fetch the schema from") var environment: Environment
        @Option(name: .shortAndLong, parsing: .next, help: "valid envoy username") var username: String
        @Option(name: .shortAndLong, parsing: .next, help: "valid envoy password") var password: String
        
        func run() async throws {
            let fileStructure = try FileStructure()
            CodegenLogger.log("File structure: \(fileStructure)")

            let folderForDownloadedSchema = fileStructure.sourceRootURL
                            .apollo.childFolderURL(folderName: "EnvoyMobile")
                            .apollo.childFolderURL(folderName: "Modules")
                            .apollo.childFolderURL(folderName: "GraphQL")
            
            print("[DEBUG] - schema path: \(folderForDownloadedSchema.path)")

            // Make sure the folder is created before trying to download something to it.
            try FileManager.default.apollo.createFolderIfNeeded(at: folderForDownloadedSchema)

            let jwtToken = try await AuthenticationService().getJWT(for: environment, username: username, password: password)
            
            let graphQLUrl = environment.url.appendingPathComponent("graphql")

            let apolloConfiguration = ApolloSchemaDownloadConfiguration(
                using: .introspection(endpointURL: graphQLUrl),
                headers: [.init(key: "Authorization", value: "Bearer \(jwtToken)")],
                outputFolderURL: folderForDownloadedSchema
            )

            try ApolloSchemaDownloader.fetch(with: apolloConfiguration)
        }
    }
    
    /// The sub-command to actually generate code.
    struct GenerateCode: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "generate",
            abstract: "Generates swift code from your schema + your operations based on information set up in the `GenerateCode` command.")
        
        func run() throws {
            let fileStructure = try FileStructure()
            CodegenLogger.log("File structure: \(fileStructure)")
            
            // Get the root of the target for which you want to generate code.
            let targetRootURL = fileStructure.sourceRootURL
                .apollo.childFolderURL(folderName: "EnvoyMobile")
                .apollo.childFolderURL(folderName: "Modules")
                .apollo.childFolderURL(folderName: "GraphQL")
            
            // Make sure the folder exists before trying to generate code.
            try FileManager.default.apollo.createFolderIfNeeded(at: targetRootURL)

            // Create the Codegen options object. This default setup assumes `schema.graphqls` is in the target root folder, all queries are in some kind of subfolder of the target folder and will output as a single file to `API.swift` in the target folder. For alternate setup options, check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloCodegenOptions/
            let codegenOptions = ApolloCodegenOptions(targetRootURL: targetRootURL)
            
            // Actually attempt to generate code.
            try ApolloCodegen.run(from: targetRootURL,
                                  with: fileStructure.cliFolderURL,
                                  options: codegenOptions)
        }
    }

    /// A sub-command which lets you download the schema then generate swift code.
    ///
    /// NOTE: This will both take significantly longer than code generation alone and fail when you're offline, so this is not recommended for use in a Run Phase Build script that runs with every build of your project.
    struct DownloadSchemaAndGenerateCode: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "all",
            abstract: "Downloads the schema and generates swift code. NOTE: Not recommended for use as part of a Run Phase Build Script.")

        func run() async throws {
            try await DownloadSchema().run()
            try GenerateCode().run()
        }
    }
}

@main
struct MainApp {
    static func main() async {
        await GraphQLTool.main()
    }
}
