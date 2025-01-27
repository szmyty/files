# ⚙️ Set Up Kubernetes Cluster

## Description
Set up a single-node Kubernetes cluster locally to serve as the foundation for deploying the application. This task is critical for testing the scalability and modularity of the system before extending to a more complex infrastructure.

---

## Task Breakdown

### **Install Kubernetes**
- [ ] Install a lightweight Kubernetes distribution (e.g., Minikube, Kind, or K3s) locally.
- [ ] Verify the installation by creating and managing basic Kubernetes resources (e.g., pods, services).

### **Create a Single-Node Cluster**
- [ ] Set up a single-node Kubernetes cluster.
- [ ] Test the cluster’s functionality by deploying a simple test service.

### **Deploy the Mock API Server**
- [ ] Package the mock API server (from the previous issue) into a Docker container.
- [ ] Deploy the container to the Kubernetes cluster using a `Deployment` resource.
- [ ] Expose the service using a `Service` resource (e.g., NodePort or ClusterIP).

### **Verify and Document**
- [ ] Verify that the service is accessible locally (e.g., `http://localhost:PORT`).
- [ ] Document the setup process, including commands and configurations, for future reference.

---

## Acceptance Criteria
- [ ] Kubernetes is installed and running locally.
- [ ] A single-node Kubernetes cluster is set up and functioning.
- [ ] The mock API server is deployed to the cluster and accessible locally.
- [ ] Documentation is provided for the setup and deployment process.

---

## Notes
- **Tool Options**:
  - Use **Minikube** for simplicity or **Kind** (Kubernetes in Docker) for a lightweight setup.
  - Alternatively, use **K3s** for a production-grade single-node cluster.
- **Dependencies**:
  - The mock API server should be containerized before deployment.

