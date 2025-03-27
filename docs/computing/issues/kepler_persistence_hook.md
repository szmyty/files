## 🗺️ KeplerGL Map Persistence — Design Summary & Architecture

This is a snapshot of the architectural approach for persisting map state in the KeplerGL-based app, after encountering serialization issues with Redux state.

---

### ❗ Why This Approach Was Necessary

KeplerGL stores complex internal state, including functions and non-serializable objects. Using redux-persist directly on this reducer caused issues due to JSON.stringify-based serialization.

Instead, KeplerGL exposes a proper serialization/deserialization API:

```typescript
KeplerGlSchema.save(state)   // ✅ Safely serializes state
KeplerGlSchema.load(datasets, config)  // ✅ Rehydrates from saved data
```

Using these ensures full compatibility and avoids runtime hydration errors.

---

### ✅ Design Overview

To handle persistence cleanly, I created a custom React hook:  
```typescript 
useKeplerPersistence({ mapKey, reducerKey })
```

This hook:
- Waits for the app to mount
- Reads any cached map state from IndexedDB
- If found, hydrates the map using:

```typescript
dispatch(addDataToMap(KeplerGlSchema.load(datasets, config)));
```

- Otherwise, allows Kepler to fall back to default reducer state

It also:
- Listens for state changes in `keplerGl` reducer
- Debounces saves using `KeplerGlSchema.save(...)`
- Writes to IndexedDB using `idb-keyval` with version tagging

---

### 📂 Code Snippets

**Hydration on Startup:**

```typescript
const saved = await get('kepler_map_config');
if (saved?.version === 'v1') {
  const { datasets, config } = saved.savedMap;
  dispatch(addDataToMap(KeplerGlSchema.load(datasets, config)));
}
```

**Debounced Save:**

```typescript
const config = KeplerGlSchema.save(state);
await set('kepler_map_config', {
  version: 'v1',
  savedMap: config,
  timestamp: Date.now(),
});
```

---

### 🧩 Component Integration

To ensure KeplerGL reads from the correct Redux slice, we match their demo:

```typescript
const keplerGlGetState = state => state.demo.keplerGl;

<KeplerGl
  id="main"
  getState={keplerGlGetState}
  ...
/>
```

---

### 🔁 Next Steps

1. ✅ **Remove `redux-persist`** — it is no longer needed for `keplerGl` state  
2. ✅ **Replace with** `useKeplerPersistence` for map caching  
3. 🔍 **Test**: Add layers → refresh browser → confirm they are restored correctly from cache

---

### ℹ️ What is a Hook?

A “hook” is a function in React that lets you tap into lifecycle behavior (like mounting, updating, cleanup) and state management inside functional components.  
Here, we use it to handle the map hydration/save logic without polluting the main component logic.

---
