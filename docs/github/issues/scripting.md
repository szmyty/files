# 🛠️ Develop Data Transformation Scripts

## Description
Develop modular Python scripts for transforming raw geospatial data into formats compatible with the visualization tool (e.g., GeoJSON, CSV). These scripts will form the foundation for automating the transformation process in future milestones (e.g., through Kestra), but for now, they will be runnable manually.

The transformation scripts should:
- Support flexible input formats (e.g., NetCDF).
- Output data in visualization-ready formats (e.g., GeoJSON, CSV).
- Be designed with modularity in mind, allowing for future hooks or custom extensions.

---

## Task Breakdown

### Build Modular Transformation Scripts
- [ ] Create a Python script for converting NetCDF files to GeoJSON or CSV.
- [ ] Add support for additional hooks or parameters to customize the transformation process for specific user needs.

### Test with Mock Data
- [ ] Use mock NetCDF files to validate the transformation script.
- [ ] Ensure the output conforms to the schema defined in the data layers issue.

### Document the Script
- [ ] Provide clear documentation and examples for:
  - Running the script manually.
  - Adding custom hooks for specific transformation requirements.

---

## Example Code Snippet

Here’s an example Python script for converting a **NetCDF file to CSV** with a hook for additional transformations:

```python
import netCDF4 as nc
import csv
from typing import Callable, Optional

def netcdf_to_csv(netcdf_file: str, csv_file: str, custom_transform: Optional[Callable] = None) -> None:
    """
    Convert a NetCDF file to CSV with optional custom transformation.

    Args:
        netcdf_file (str): Path to the input NetCDF file.
        csv_file (str): Path to the output CSV file.
        custom_transform (Callable, optional): A function to apply custom transformations on the data.
    """
    # Open the NetCDF file
    dataset = nc.Dataset(netcdf_file, mode="r")

    # Extract data (example assumes 'lat' and 'lon' variables)
    lat = dataset.variables.get("lat", [])[:]
    lon = dataset.variables.get("lon", [])[:]

    # Apply custom transformation if provided
    if custom_transform:
        lat, lon = custom_transform(lat, lon)

    # Write to CSV
    with open(csv_file, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["latitude", "longitude"])  # Header
        for lat_val, lon_val in zip(lat, lon):
            writer.writerow([lat_val, lon_val])

    print(f"Converted {netcdf_file} to {csv_file}")

# Example usage
def example_custom_transform(lat, lon):
    # Custom transformation example (e.g., scaling or filtering)
    return [x * 2 for x in lat], [y + 5 for y in lon]

# Run the script with a custom transformation
netcdf_to_csv("example.nc", "output.csv", custom_transform=example_custom_transform)
```

---

## Acceptance Criteria

- [ ] A Python script is created for transforming NetCDF files to GeoJSON or CSV.
- [ ] The script supports hooks for custom transformations.
- [ ] The script is tested with mock NetCDF data to validate the output format.
- [ ] Documentation is provided for running the script and extending it with custom transformations.

---

## Notes

### Why Modular Scripts?

This approach ensures the transformation logic can evolve over time and be integrated with automation tools like Kestra later.


### Why Hooks for Customization?

Hooks enable flexibility to meet specific data transformation needs without rewriting core logic.


### Future Integration:

In future milestones, these scripts will be integrated into Kestra for automated workflows.
