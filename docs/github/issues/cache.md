# 💾 Implement Offline Cache for Layers

## Description
Implement offline-first functionality for caching data layers on the frontend using Redux Persist. This ensures that Redux remains the single source of truth while allowing selective persistence of specific slices of the state (e.g., data layers) in persistent storage like `localStorage` or `IndexedDB`.

This caching strategy will enable:
- Persistent storage of data layers for offline functionality.
- Ephemeral storage for transient UI states and interactions.

---

## Task Breakdown

### Set Up Redux Persist
- [ ] Install Redux Persist:
  ```bash
  npm install redux-persist
  ```
- [ ] Configure Redux Persist to persist the `dataLayers` slice of the Redux state.
- [ ] Exclude transient UI states from persistence.

---

## Define Persisted Storage

- [ ] Use `localStorage` or `IndexedDB` as the backend for Redux Persist.
- [ ] Test the cache behavior:
  - Verify that layers are retained after a page refresh.
  - Ensure transient states are not persisted.

---

## Add TypeScript Support

- [ ] Define TypeScript types for the Redux state and persisted slices.
- [ ] Ensure strong typing for actions and reducers used in `dataLayers`.

---

## Document the Setup

- [ ] Write documentation on how Redux Persist is configured and which slices are persisted.
- [ ] Include examples of extending the persistence logic.

---

## Example Code Snippet

Here’s a TypeScript example of setting up Redux Persist for the dataLayers slice:

```
import { configureStore, combineReducers } from '@reduxjs/toolkit';
import { persistStore, persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage'; // Use localStorage as storage backend
import dataLayersReducer from './dataLayersSlice';
import uiStateReducer from './uiStateSlice';

const persistConfig = {
  key: 'root',
  storage,
  whitelist: ['dataLayers'], // Only persist dataLayers slice
};

const rootReducer = combineReducers({
  dataLayers: dataLayersReducer,
  uiState: uiStateReducer, // UI state will remain ephemeral
});

const persistedReducer = persistReducer(persistConfig, rootReducer);

export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false, // Required for Redux Persist
    }),
});

export const persistor = persistStore(store);
```

### Example Usage in a Component:

```
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from './store';
import { addLayer } from './dataLayersSlice';

const LayersComponent: React.FC = () => {
  const dispatch = useDispatch();
  const layers = useSelector((state: RootState) => state.dataLayers.layers);

  const addNewLayer = () => {
    dispatch(addLayer({ id: '123', name: 'Sample Layer', type: 'geojson' }));
  };

  return (
    <div>
      <h1>Data Layers</h1>
      <button onClick={addNewLayer}>Add Layer</button>
      <ul>
        {layers.map((layer) => (
          <li key={layer.id}>{layer.name}</li>
        ))}
      </ul>
    </div>
  );
};

export default LayersComponent;
```

---

## Acceptance Criteria

- [ ] Redux Persist is installed and configured for the dataLayers slice.
- [ ] Layers are stored persistently in localStorage or IndexedDB.
- [ ] Transient UI states (e.g., uiState) are excluded from persistence.
- [ ] The cache is validated to retain layers after a page refresh.
- [ ] TypeScript types are used throughout the implementation.
- [ ] Documentation is provided for configuring and extending Redux Persist.

---

## Notes

### Why Redux Persist?

Allows Redux to remain the single source of truth while extending its functionality with persistent storage.

Provides flexibility to decide which parts of the state are persisted and which are ephemeral.


### Why Offline Cache?

Ensures a seamless user experience when offline or on unstable network connections.

Reduces API calls by reusing cached data.

---

### **Why This Works**
1. **TypeScript Integration**:
   - Ensures strong typing for the Redux state and persisted slices, minimizing runtime errors.
2. **Selective Persistence**:
   - Focuses on caching data layers while keeping transient states ephemeral.
3. **Offline-First Design**:
   - Ensures layers are available even after a page refresh or when offline.