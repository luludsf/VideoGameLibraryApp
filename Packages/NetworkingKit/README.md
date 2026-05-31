# NetworkingKit

Camada de networking reutilizavel via Swift Package Manager.

## Estrutura

- `Sources/NetworkingKit`: implementacao do modulo.

## Como usar em outro projeto

1. No Xcode, abra `File > Add Package Dependencies...`
2. Clique em `Add Local...`
3. Selecione a pasta `Packages/NetworkingKit`
4. Importe o modulo com `import NetworkingKit`

## Exemplo

```swift
import NetworkingKit

struct GamesRequest: Request {
    let host = "api.example.com"
    let scheme = "https"
    let version = "v1"
    let path = "/games"
    let method = HTTPMethod.GET
    let headers: [String: String]? = nil
    let bodyParams: [String: Any?]? = nil
    let queryParams: [String: String]? = nil
}

let client = URLSessionClient()
let response: GamesResponse = try await client.perform(GamesRequest())
```
