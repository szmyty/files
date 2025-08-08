# System Overview

This document provides a high-level overview of the application architecture and deployment process.

---

## 1. Application Architecture

**Purpose:**  
An interactive geospatial web application built with a modular, containerized architecture.

**Core Components:**

- **Web App**  
  - Frontend user interface built with modern web technologies.  
  - Provides interactive geospatial features for end users.

- **Apache Web Server**  
  - Serves the built Web App static files.  
  - Acts as a reverse proxy for API and authentication requests.

- **Keycloak**  
  - Manages authentication and authorization for all components.  
  - Protects access to both the Web App and API endpoints.

- **API**  
  - Backend service providing application data to the Web App.  
  - Processes requests and communicates with the database.

- **Database**  
  - Stores spatial and application data.  
  - Queried directly by the API.

**Architecture Diagram:**  
![System Architecture](./images/system-architecture.png)

---

## 2. Deployment Model

**Purpose:**  
Supports local development and automated deployments to demo and production environments via Jenkins.

**Environments & Flow:**

- **Local Development**  
  - Runs inside a **VS Code DevContainer** using Docker Compose.  
  - Uses local `.env.local` configuration with test users in Keycloak.  
  - Brings up all services (Web App, Apache, Keycloak, API, Database) locally.

- **Demo Deployment**  
  - Triggered by merging to the **`demo`** branch.  
  - Jenkins pipeline builds containers, pushes to the registry, and deploys to the demo server.  
  - Uses demo-specific environment variables and secrets.

- **Production Deployment**  
  - Triggered by merging to the **`main`** branch.  
  - Same Jenkins pipeline process as demo, but deploys to production servers with production configuration.

**Deployment Diagram:**  
![Deployment Flow](./images/deployment-flow.png)

---

## 3. Key Notes for New Maintainers

- **Configuration**  
  - Environment variables (`.env`) control service URLs, secrets, and realm configurations.  
  - Each environment has its own `.env` file.

- **Authentication**  
  - Keycloak realms and clients differ between environments.  
  - All requests to the API must include a valid token from Keycloak.

- **Data Layer**  
  - The database stores all geospatial and application data.  
  - Schema changes should be applied consistently across environments.

- **Build & Deployment**  
  - All services are containerized and orchestrated via Docker Compose.  
  - Jenkins handles building, pushing, and deploying automatically based on branch merges.

---
