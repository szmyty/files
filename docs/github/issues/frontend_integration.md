# 🔗 Integrate Frontend with API Server

## Description
Integrate the frontend (Kepler-GL) with the API server to enable data fetching for mock data layers. This task will ensure the frontend can fetch and display layers from the API server while verifying compatibility with the data schema.

---

## Task Breakdown

### Connect Frontend to API Server
- [ ] Update the frontend to fetch data from the API server’s `/layers` endpoint or GraphQL queries.
- [ ] Parse the data returned by the API server to ensure it matches the schema expected by Kepler-GL.

### Display Mock Layers in Kepler-GL
- [ ] Configure the Kepler-GL map to render mock layers fetched from the API server.
- [ ] Test that layers are displayed correctly (e.g., scatterplot, heatmap).

### Handle Data Transformations
- [ ] Add logic to transform data (if needed) from the API server to a format compatible with Kepler-GL.
- [ ] Document any assumptions or decisions made for data formatting.

### Error Handling and Logging
- [ ] Implement error handling for API failures (e.g., server unreachable, invalid data).
- [ ] Add debug logs to assist with troubleshooting during integration.

### Testing and Validation
- [ ] Test that the frontend can dynamically fetch and display layers from the API server.
- [ ] Validate that Kepler-GL correctly renders the fetched layers.
- [ ] Ensure mock data can be extended to support additional fields or views.

---

## Example Code Snippet
Here’s an example of a function to fetch layers from the API server:

```javascript
async function fetchLayers() {
  try {
    const response = await fetch("http://localhost:5000/layers"); // Replace with actual API URL
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const layers = await response.json();
    return layers;
  } catch (error) {
    console.error("Error fetching layers:", error);
  }
}
```

---

## Acceptance Criteria

- [ ] The frontend fetches data from the API server successfully.
- [ ] Kepler-GL displays mock layers fetched from the API server.
- [ ] Data transformations (if required) are implemented and documented.
- [ ] Error handling and logging are in place.

---

## Notes

Ensure the frontend uses the schema defined in the API server (e.g., metadata, raw references, compatible views).

Mock data should align with the schema and test various visualization types (e.g., scatterplot, heatmap).

This integration will lay the groundwork for connecting to the real datastore in the future.