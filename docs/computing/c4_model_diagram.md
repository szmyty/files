# C4 Model Overview

The C4 model provides four different perspectives, or levels of abstraction, to represent software architecture. Each perspective focuses on different aspects of the system and is tailored to different audiences.

## 1. Context Diagram
**Perspective**: High-level external view.  
**Focus**: The system's environment and its interactions with external entities (such as users, other systems, and external services).  
**Audience**: Non-technical stakeholders (e.g., business sponsors, end-users).

### Example
```plantuml
@startuml
actor Customer
actor Admin

package "E-commerce System" {
    [Web Application] 
    [REST API]
    [Database]
}

Customer --> [Web Application]
Admin --> [Web Application]
[Web Application] --> [REST API]
[REST API] --> [Database]
@enduml
```

## 2. Container Diagram
**Perspective**: High-level internal view.  
**Focus**: The main containers (applications or services) that make up the system, their responsibilities, and their interactions.  
**Audience**: Both technical and non-technical stakeholders who need an understanding of the system’s structure.

### Example
```plantuml
@startuml
node "Web Application" {
    [Frontend]
    [Backend]
}

node "REST API" {
    [Auth Service]
    [Product Catalog Service]
    [Order Management Service]
}

node "Database" {
    [User DB]
    [Product DB]
    [Order DB]
}

[Frontend] --> [Backend]
[Backend] --> [Auth Service]
[Backend] --> [Product Catalog Service]
[Backend] --> [Order Management Service]

[Auth Service] --> [User DB]
[Product Catalog Service] --> [Product DB]
[Order Management Service] --> [Order DB]
@enduml
```

## 3. Component Diagram
**Perspective**: Mid-level internal view.  
**Focus**: The components within each container, their responsibilities, and interactions.  
**Audience**: Developers and architects who need detailed information on the internals of each container.

### Example
```plantuml
@startuml
package "Auth Service" {
    [Login Controller]
    [Registration Controller]
    [User Repository]
    [Token Service]
}

[Login Controller] --> [User Repository]
[Registration Controller] --> [User Repository]
[Login Controller] --> [Token Service]
@enduml
```

## 4. Code (or Class) Diagram
**Perspective**: Low-level internal view.  
**Focus**: The internal structure of the components, typically represented by classes, interfaces, and their relationships.  
**Audience**: Developers working on the implementation of the system.

### Example
```plantuml
@startuml
class LoginController {
    - UserRepository userRepository
    - TokenService tokenService
    + login(username: String, password: String): Token
}

class UserRepository {
    + findByUsername(username: String): User
}

class TokenService {
    + generateToken(user: User): Token
}

LoginController --> UserRepository
LoginController --> TokenService
@enduml
```

---

## Summary of the C4 Model Perspectives
- **Context Diagram**: Provides a broad, high-level view of the system in its environment, highlighting interactions with external actors.
- **Container Diagram**: Breaks the system into high-level containers and shows how they interact within the system.
- **Component Diagram**: Zooms into a specific container to show the internal components and their interactions.
- **Code Diagram**: Offers the most detailed view, focusing on the internal structure of the components at the code level.

By using these four perspectives, the C4 model allows for a comprehensive understanding of the software architecture at different levels of detail, making it easier to communicate with various stakeholders and ensuring that the architecture is well-documented and understood.