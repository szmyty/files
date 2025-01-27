# 🛠️ Setup API Server

## Description

Decide on and implement the initial version of the backend API server. This API will enable the frontend to fetch data layers from the datastore (future issue) or, for now, use a mock datastore.

Currently, we are leaning towards **GraphQL with Apollo Server**, but we should also consider a **REST API with Flask** for simplicity. Below is a comparison table to evaluate the trade-offs.

---

## Comparison: GraphQL (Apollo) vs REST (Flask)

| Feature                     | **GraphQL (Apollo)**                                                       | **REST API (Flask)**                                                    |
|-----------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------|
| **Data Fetching**           | Flexible querying allows fetching only the data needed in a single request. | Predefined endpoints require multiple calls for complex or nested data. |
| **Hierarchical Data**       | Ideal for geospatial layers with nested relationships (e.g., layers → metadata → fields). | Requires additional endpoints or nesting logic to retrieve related data. |
| **Versioning**              | No versioning required; schemas can evolve without breaking clients.       | Requires versioning (e.g., `/v1/layers`, `/v2/layers`) for schema changes. |
| **Real-Time Updates**       | Built-in support via GraphQL subscriptions.                               | Requires WebSockets or another protocol for real-time data.             |
| **Performance**             | Slightly more overhead due to resolvers and query parsing.                | Lightweight, especially for simple CRUD operations.                     |
| **Ease of Setup**           | Slightly steeper learning curve but highly scalable.                      | Easier for straightforward, flat APIs.                                  |
| **Flexibility**             | Excellent for dynamic and hierarchical queries.                           | Limited to predefined endpoints unless manually expanded.               |
| **Learning Opportunity**    | Great for learning modern API design and GraphQL concepts.                | Familiar and straightforward.                                           |

Based on this comparison, **GraphQL with Apollo Server** is the likely choice for its flexibility, scalability, and ability to handle nested queries efficiently.

---

## Example GraphQL Schema

Below is an example schema that matches the data layer schema from the previous issue:

```graphql
type Metadata {
  description: String
  source: String
}

type Field {
  name: String!
  type: String!
}

type CompatibleView {
  type: String!
}

type Layer {
  id: ID!
  type: String!
  name: String!
  raw: Raw
  fields: [Field!]!
  metadata: Metadata
  compatibleViews: [CompatibleView!]!
  defaultView: String!
}

type Raw {
  source: String!
  format: String!
  size: Int
}

type Query {
  layers: [Layer!]! # Fetch all layers
  layer(id: ID!): Layer # Fetch a specific layer by ID
}
```

## Example Query

To fetch layers along with their metadata:

```graphql
query {
  layers {
    id
    name
    type
    metadata {
      description
    }
  }
}
```

---

## Task Breakdown

### **Decide on API Server**

- [ ] Evaluate the trade-offs between GraphQL (Apollo) and REST (Flask) using the table above.
- [ ] Confirm whether to proceed with GraphQL or REST as the backend API.

### **Implement the Initial Server**

- [ ] Set up the API server:
  - If GraphQL (Apollo Server):
    - Install Apollo Server and define an initial schema with basic queries for fetching mock data layers.
    - Example queries: `layers`, `layer(id)`.
  - If REST (Flask):
    - Install Flask and set up basic endpoints (e.g., `/layers`, `/layers/:id`).
- [ ] Use a **mock datastore** for now (e.g., an in-memory array of layers).
  - Example Mock Data:

    ```json
    [
      { "id": "1", "name": "Layer 1", "type": "geojson" },
      { "id": "2", "name": "Layer 2", "type": "csv" }
    ]
    ```

- [ ] Test the API server by fetching mock data from the frontend.

---

## Acceptance Criteria

- [ ] A backend API server is implemented using either GraphQL (Apollo Server) or REST (Flask).
- [ ] The server provides a basic endpoint or query to fetch mock data layers.
- [ ] The API server can connect to the frontend for initial data fetching.
- [ ] The mock datastore can be replaced with a real datastore in a future issue.

---

## Notes

This is an initial version of the backend API server, designed to get the frontend working with mock data.
The architecture should allow for future extensions (e.g., connecting to TileDB or another datastore, handling real-time updates).
