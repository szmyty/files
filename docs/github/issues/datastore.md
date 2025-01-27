# 🗄️ Decide and Set Up the Datastore

## Description
Evaluate and implement the backend datastore for managing geospatial data layers. This datastore will serve as the foundation for storing, querying, and serving data to the API server. The initial implementation will use mock data to validate the integration and ensure compatibility with the schema and API server.

---

## Task Breakdown

### Evaluate Datastore Options
Compare potential options for the datastore based on scalability, ease of setup, and geospatial capabilities:

| **Datastore**        | **Pros**                                                                 | **Cons**                                                                                       |
|----------------------|-------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| **TileDB**           | - Optimized for geospatial and multidimensional data.<br>- High performance for querying and storage.<br>- Supports binary formats like FlatBuffers. | - More complex to set up.<br>- Requires a learning curve.<br>- May require additional tooling for transformations. |
| **PostGIS**          | - Standard SQL-based geospatial extension for PostgreSQL.<br>- Rich geospatial query support (e.g., bounding boxes, projections).<br>- Well-supported in the industry. | - Overhead of managing a relational database.<br>- Requires tuning for larger datasets.       |
| **CrateDB**          | - SQL-based with built-in geospatial support.<br>- Horizontally scalable.<br>- Open source and simple to query. | - Less mature geospatial ecosystem compared to PostGIS.<br>- Relies on SQL-based tools for advanced features. |
| **Flat Files (JSON)**| - Easiest to set up.<br>- Works well with small datasets.<br>- No backend dependencies initially.            | - Not scalable for large datasets.<br>- Limited query capabilities without loading everything into memory. |

---

### Select and Set Up the Datastore
- [ ] Choose the datastore that best fits the project needs based on scalability, ease of setup, and compatibility with the system.
- [ ] Install and configure the chosen datastore locally.

### Populate with Mock Data
- [ ] Create mock geospatial datasets (e.g., GeoJSON or CSV).
- [ ] Populate the datastore with mock data for testing.

### Test Integration with API Server
- [ ] Ensure the datastore can serve data to the API server.
- [ ] Validate compatibility with the data schema and API endpoints.

---

## Acceptance Criteria
- [ ] A datastore is selected and set up locally.
- [ ] The datastore is populated with mock geospatial data.
- [ ] The API server can query the datastore for data layers.
- [ ] Documentation is provided for setting up the datastore and populating it with data.

---

## Notes
- **Why This Task?**
  - The datastore serves as the backbone for the system, enabling scalable and efficient management of geospatial data layers.
- **Focus on Mock Data**:
  - The initial implementation will use mock data to validate the integration and ensure the system works end-to-end.
- **Future Iterations**:
  - The selected datastore should be extensible to support future automation (e.g., Kestra workflows) and scalability.