## Persistent State Integration Debug Report

### Overview

I'm working on integrating persistent browser storage into our Kepler.GL-based map application to ensure that custom-added layers and map state persist across page refreshes. This functionality is crucial for user experience, especially when interacting with dynamic layers or saved views.

### Problem

The current issue lies in how Redux Persist interacts with Kepler.GL's internal Redux store. While persistence is partially working, rehydration leads to **inconsistent or broken application state**, often accompanied by confusing or misleading errors (e.g., "match5 is not a function").

This suggests that:

- **Non-serializable elements** may be present in the persisted Redux state.
- **Automatic deserialization** is attempting to rehydrate complex objects (like functions or class instances) in ways that Kepler.GL does not expect.
- The **application lifecycle order**—especially Redux hydration versus Kepler's store setup—may be misaligned.

### Root Cause Hypothesis

The likely root cause is that parts of Kepler's internal state are not meant to be serialized and restored literally. Redux Persist is saving the entire state tree, including complex objects, and when these are deserialized, their structure is altered or functions become invalid.

### Current Strategy

To resolve this:

1. **Identify only the essential parts of state** needed for persistence (e.g., layers, map configuration).
2. Configure Redux Persist to **persist only those specific state slices**, avoiding anything non-serializable.
3. Implement a mechanism to **initialize the map state only once** on first load, and then defer to the persisted state on subsequent reloads.
4. Use Redux DevTools and lifecycle logging to trace hydration behavior and confirm expected flow.

### Goal

The goal is to achieve consistent, safe state persistence across reloads, without causing hydration mismatches or runtime errors. Once complete, this will make the app more stable and user-friendly while reducing error-prone edge cases.