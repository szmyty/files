import React from "react";
import { Box } from "@chakra-ui/react";
import DeckGL from "@deck.gl/react";
import { HeatmapLayer } from "@deck.gl/aggregation-layers";
import { Map } from "react-map-gl/maplibre";

interface IGISMapViewProps {
  data?: string | [longitude: number, latitude: number, count: number][];
  intensity?: number;
  threshold?: number;
  radiusPixels?: number;
  mapStyle?: string;
}

const INITIAL_VIEW_STATE = {
  longitude: -73.75,
  latitude: 40.73,
  zoom: 9,
  maxZoom: 16,
  pitch: 0,
  bearing: 0,
};

const DEFAULT_MAP_STYLE =
  "https://basemaps.cartocdn.com/gl/dark-matter-nolabels-gl-style/style.json";

const GISMapView = ({
  data = "https://raw.githubusercontent.com/visgl/deck.gl-data/master/examples/screen-grid/uber-pickup-locations.json",
  intensity = 1,
  threshold = 0.03,
  radiusPixels = 30,
  mapStyle = DEFAULT_MAP_STYLE,
}: IGISMapViewProps) => {
  const layers = [
    new HeatmapLayer({
      data,
      id: "heatmap-layer",
      pickable: false,
      getPosition: (d: [number, number, number]) => [d[0], d[1]],
      getWeight: (d: [number, number, number]) => d[2],
      radiusPixels,
      intensity,
      threshold,
    }),
  ];

  return (
    <Box position="absolute" top={0} left={0} right={0} bottom={0} zIndex={0}>
      <DeckGL
        initialViewState={INITIAL_VIEW_STATE}
        controller={true}
        layers={layers}
      >
        <Map reuseMaps mapStyle={mapStyle} />
      </DeckGL>
    </Box>
  );
};

export default GISMapView;
