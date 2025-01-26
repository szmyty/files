# 🚀 Deploy Application Locally with Pulumi

## Description
Set up Pulumi to automate the deployment of the Kubernetes cluster and associated services locally. This task will focus on creating infrastructure as code (IaC) scripts to streamline the deployment process and ensure consistency across environments.

---

## Task Breakdown

### Initialize Pulumi Project
- [ ] Install Pulumi CLI and authenticate with your Pulumi account.
- [ ] Initialize a new Pulumi project for the application.
  - Use TypeScript as the programming language for Pulumi scripts.
- [ ] Configure the Pulumi stack for local development.

### Define Kubernetes Resources
- [ ] Write Pulumi code to provision the Kubernetes cluster (single-node setup from the previous issue).
- [ ] Add resources for:
  - Mock API server deployment.
  - Kubernetes `Service` to expose the API server.
  - Any additional deployments/services required.
- [ ] Test deploying the cluster and services locally.

### Automate Deployment with Pulumi
- [ ] Create Pulumi scripts to automate the full deployment process:
  - Provision the Kubernetes cluster.
  - Deploy the mock API server and any other services.
  - Configure Caddy server (if needed) as part of the deployment.

### Document Pulumi Workflow
- [ ] Write clear documentation for:
  - Installing Pulumi and setting up the project.
  - Running the deployment locally (e.g., `pulumi up`).
  - Destroying resources when done (e.g., `pulumi destroy`).
  - Debugging common issues.

---

## Example Pulumi Script
Here’s a basic example of using Pulumi to deploy a mock API server:

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as k8s from "@pulumi/kubernetes";

// Create a Kubernetes namespace
const namespace = new k8s.core.v1.Namespace("app-namespace");

// Deploy a mock API server
const apiServerDeployment = new k8s.apps.v1.Deployment("mock-api-server", {
    metadata: { namespace: namespace.metadata.name },
    spec: {
        replicas: 1,
        selector: { matchLabels: { app: "api-server" } },
        template: {
            metadata: { labels: { app: "api-server" } },
            spec: {
                containers: [
                    {
                        name: "api-server",
                        image: "mock-api-server:latest",
                        ports: [{ containerPort: 5000 }],
                    },
                ],
            },
        },
    },
});

// Expose the API server via a Kubernetes service
const apiServerService = new k8s.core.v1.Service("api-server-service", {
    metadata: { namespace: namespace.metadata.name },
    spec: {
        selector: { app: "api-server" },
        ports: [{ port: 80, targetPort: 5000 }],
        type: "NodePort",
    },
});

export const apiServerUrl = pulumi.interpolate`http://${apiServerService.metadata.name}:80`;
```

---

## Acceptance Criteria

[ ] Pulumi project is initialized and configured for local development.

[ ] Pulumi scripts provision the Kubernetes cluster and deploy the mock API server.

[ ] The application can be accessed locally via the Kubernetes cluster.

[ ] Documentation is provided for setting up, deploying, and tearing down the infrastructure with Pulumi.

---

## Notes

### Why Pulumi?

Pulumi simplifies infrastructure management with a code-first approach, making it easier to maintain and extend deployments over time.