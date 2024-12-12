#!/usr/bin/env bash
set -e

# Create project directory
mkdir -p my-geospatial-demo
cd my-geospatial-demo

# Initialize a default package.json
pnpm init --yes

# Overwrite package.json with our desired content (without specifying versions)
cat <<EOF > package.json
{
  "name": "my-geospatial-demo",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "vite --port 5173",
    "build": "vite build",
    "preview": "vite preview"
  }
}
EOF

# Create tsconfig.json
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "strict": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
EOF

# Create vite.config.ts
cat <<EOF > vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173
  }
});
EOF

# Create index.html
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Geospatial Demo</title>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.tsx"></script>
</body>
</html>
EOF

# Create src directory and subdirectories
mkdir -p src/store
mkdir -p src/components
mkdir -p src/styles
mkdir -p src/types

# Create main.tsx
cat <<EOF > src/main.tsx
import React from "react";
import ReactDOM from "react-dom/client";
import { Provider } from "react-redux";
import { store } from "./store";
import App from "./App";
import "./styles/global.css";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>
);
EOF

# Create App.tsx
cat <<EOF > src/App.tsx
import React from "react";
import { AppShell, Container, Grid } from "@mantine/core";
import AppHeader from "./components/AppHeader";
import LayerInfo from "./components/LayerInfo";
import DataChart from "./components/DataChart";
import MapView from "./components/MapView";

const App: React.FC = () => {
  return (
    <AppShell
      padding="md"
      header={<AppHeader />}
      styles={(theme) => ({
        main: {
          backgroundColor: theme.colors.gray[0]
        }
      })}
    >
      <Container fluid>
        <Grid gutter="md">
          <Grid.Col span={4}>
            <div style={{ marginBottom: "1rem" }}>
              <LayerInfo />
            </div>
            <div>
              <DataChart />
            </div>
          </Grid.Col>
          <Grid.Col span={8}>
            <MapView />
          </Grid.Col>
        </Grid>
      </Container>
    </AppShell>
  );
};

export default App;
EOF

# Create store/index.ts
cat <<EOF > src/store/index.ts
import { configureStore } from "@reduxjs/toolkit";
import mapReducer from "./mapSlice";

export const store = configureStore({
  reducer: {
    map: mapReducer
  }
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
EOF

# Create store/mapSlice.ts
cat <<EOF > src/store/mapSlice.ts
import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface MapState {
  zoom: number;
  layerName: string;
}

const initialState: MapState = {
  zoom: 4,
  layerName: "Heatmap Layer"
};

const mapSlice = createSlice({
  name: "map",
  initialState,
  reducers: {
    setZoom(state, action: PayloadAction<number>) {
      state.zoom = action.payload;
    },
    setLayerName(state, action: PayloadAction<string>) {
      state.layerName = action.payload;
    }
  }
});

export const { setZoom, setLayerName } = mapSlice.actions;
export default mapSlice.reducer;
EOF

# Create components/AppHeader.tsx
cat <<EOF > src/components/AppHeader.tsx
import React from "react";
import { Header, Title, ActionIcon, Group } from "@mantine/core";

const AppHeader: React.FC = () => {
  return (
    <Header height={60} p="md" style={{ display: "flex", alignItems: "center" }}>
      <Group position="apart" style={{ width: "100%" }}>
        <Title order={3}>My Geospatial Demo</Title>
        <ActionIcon variant="light" title="Settings">
          <span>⚙️</span>
        </ActionIcon>
      </Group>
    </Header>
  );
};

export default AppHeader;
EOF

# Create components/LayerInfo.tsx
cat <<EOF > src/components/LayerInfo.tsx
import React from "react";
import { Card, Text } from "@mantine/core";
import { useSelector } from "react-redux";
import { RootState } from "../store";

const LayerInfo: React.FC = () => {
  const layerName = useSelector((state: RootState) => state.map.layerName);

  return (
    <Card shadow="sm" padding="lg" radius="md" withBorder>
      <Text weight={500} size="lg">{layerName}</Text>
      <Text size="sm" color="dimmed" style={{ marginTop: "0.5rem" }}>
        This layer shows a simple heatmap visualization of dummy data.
      </Text>
    </Card>
  );
};

export default LayerInfo;
EOF

# Create components/DataChart.tsx
cat <<EOF > src/components/DataChart.tsx
import React, { useRef } from "react";
import { BarChart, BarSeries, CategoryAxis, ValueAxis } from "@unovis/react";

const DataChart: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const data = [
    { category: "A", value: 10 },
    { category: "B", value: 40 },
    { category: "C", value: 25 },
    { category: "D", value: 35 }
  ];

  return (
    <div style={{ width: "100%", height: "200px" }} ref={containerRef}>
      <BarChart data={data} container={containerRef.current}>
        <CategoryAxis field="category" />
        <ValueAxis field="value" />
        <BarSeries x="category" y="value" />
      </BarChart>
    </div>
  );
};

export default DataChart;
EOF

# Create components/MapView.tsx
# Using Deck.gl with a basic tile layer from OpenStreetMap through a generic TileLayer.
# Remove map tokens for simplicity. Display a heatmap on top of OSM tiles.
cat <<EOF > src/components/MapView.tsx
import React, { useState } from "react";
import DeckGL from "@deck.gl/react/typed";
import { HeatmapLayer } from "@deck.gl/aggregation-layers/typed";
import { TileLayer } from "@deck.gl/geo-layers/typed";

const data = [
  { position: [-74.1, 40.7], weight: 1 },
  { position: [-74.0, 40.7], weight: 2 },
  { position: [-73.9, 40.7], weight: 3 }
];

const MapView: React.FC = () => {
  const [initialViewState] = useState({
    longitude: -74.0,
    latitude: 40.7,
    zoom: 9,
    pitch: 0,
    bearing: 0
  });

  const heatmapLayer = new HeatmapLayer({
    id: "heatmap-layer",
    data: data,
    getPosition: (d: any) => d.position,
    getWeight: (d: any) => d.weight,
    radiusPixels: 60
  });

  const tileLayer = new TileLayer({
    id: "osm-tiles",
    data: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
    minZoom: 0,
    maxZoom: 19,
    tileSize: 256,
    renderSubLayers: (props) => {
      const { tile } = props;
      return new DeckGL.layers.BitmapLayer(props, {
        data: null,
        image: tile.data,
        bounds: tile.bbox
      });
    }
  });

  return (
    <DeckGL
      initialViewState={initialViewState}
      controller={true}
      layers={[tileLayer, heatmapLayer]}
      style={{ position: "relative", width: "100%", height: "80vh" }}
    />
  );
};

export default MapView;
EOF

# Create styles/global.css
cat <<EOF > src/styles/global.css
html, body, #root {
  margin: 0;
  padding: 0;
  height: 100%;
  font-family: sans-serif;
}
EOF

# Create types/index.d.ts
cat <<EOF > src/types/index.d.ts
// Custom type definitions can go here.
// For now, this file is empty.
EOF

# Add dependencies using pnpm with latest versions
pnpm add --save-prod react react-dom @mantine/core @mantine/hooks @unovis/react deck.gl @deck.gl/react @deck.gl/aggregation-layers @deck.gl/geo-layers @reduxjs/toolkit react-redux
pnpm add --save-prod vite @vitejs/plugin-react

# Add dev dependencies
pnpm add --save-dev typescript @types/react @types/react-dom @types/node

echo "Project setup complete!"
echo "You can now:"
echo "1. Change into the directory: cd my-geospatial-demo"
echo "2. Run the development server: pnpm run dev"
echo "Then open http://localhost:5173 in your browser."
