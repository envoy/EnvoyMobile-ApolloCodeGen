# ApolloCodegen

This executable swift package is used to perform various Apollo GraphQL tasks including
- Downloading the GraphQL schema
- generating the `API.swift` file

## Usage

To run this repo

`swift run gql -h`

## Compiling a binary

from the directory with the `Package.swift` file:

```bash
swift build --product gql -c release --arch arm64 --arch x86_64
```

you can verify the available architectures of the binary with:

`lipo -info path/to/binary/gql`

This will create a `gql` binary in the [build](./.build/apple/Products/Release) folder
You can drop this into the Modules/GraphQL folder in EnvoyMobile if you ever need to update the binary.
