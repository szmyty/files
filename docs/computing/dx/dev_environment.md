## 🚀 Installation & Development Setup

This project uses **Pulumi, Kubernetes, and Taskfile** for infrastructure automation and local-first development. The goal is to provide a **push-to-start** experience, making it easy to deploy and manage the system with minimal manual setup.

### **📌 Development Environment Setup**
Before running the system, you need to install a few key dependencies. We use **Taskfile** to automate the setup process, ensuring a consistent environment across different machines. The setup process will:
- Install **Pulumi** (for Infrastructure as Code).
- Install **Minikube** (for running Kubernetes locally).
- Install **kubectl** (for interacting with Kubernetes).
- Verify that all required dependencies are installed correctly.

### **1️⃣ Install Taskfile**
Taskfile automates common commands and environment setup.

#### **MacOS / Linux**
```sh
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d
```

#### **Windows (Using Scoop)**
```sh
scoop install task
```

### **Verify Taskfile Installation**
To ensure Taskfile is installed correctly, run:

```sh
task --version
```

If you see the Taskfile version number, the installation was successful.

### **2️⃣ Run Dev Environment Setup**
Once Taskfile is installed, run:

```sh
task setup
```

This will:
- Install **Pulumi**
- Install **Minikube** (for local Kubernetes)
- Install **kubectl**

### **🔍 Verifying the Installation**
Run the following command to confirm everything is installed correctly:

```sh
pulumi version && minikube version && kubectl version --client
```

If all commands return versions, the setup was successful.
