#!/bin/bash

# DeepFace Kubernetes Deployment Script
# Usage: ./deploy.sh [action]
# Actions: deploy, delete, status, logs, scale, update

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="default"
BACKEND_DEPLOYMENT="deepface-backend"
FRONTEND_DEPLOYMENT="deepface-frontend"
BACKEND_IMAGE="shefanny00/deepface-backend:latest"
FRONTEND_IMAGE="shefanny00/deepface-frontend:latest"

# Functions
print_status() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Deploy function
deploy() {
  print_status "Starting deployment..."
  
  print_status "Deploying backend..."
  kubectl apply -f deployment-backend.yaml
  
  print_status "Waiting for backend to be ready..."
  kubectl rollout status deployment/$BACKEND_DEPLOYMENT -n $NAMESPACE --timeout=5m
  
  print_status "Deploying frontend..."
  kubectl apply -f deployment-frontend.yaml
  
  print_status "Waiting for frontend to be ready..."
  kubectl rollout status deployment/$FRONTEND_DEPLOYMENT -n $NAMESPACE --timeout=5m
  
  print_status "Deploying HPA (Horizontal Pod Autoscaler)..."
  kubectl apply -f hpa.yaml
  
  print_status "Waiting for HPA to be ready..."
  sleep 3
  
  print_status "✓ Deployment completed successfully!"
  
  print_status "Getting service information..."
  kubectl get svc deepface-frontend-service -n $NAMESPACE
  
  print_status "HPA Status:"
  kubectl get hpa -n $NAMESPACE
}

# Delete function
delete() {
  print_warning "Deleting deployments..."
  read -p "Are you sure? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete -f hpa.yaml
    kubectl delete -f deployment-frontend.yaml
    kubectl delete -f deployment-backend.yaml
    print_status "✓ Deployments deleted"
  fi
}

# Status function
status() {
  print_status "Backend Deployment Status:"
  kubectl get deployment $BACKEND_DEPLOYMENT -n $NAMESPACE
  print_status "Backend Pods:"
  kubectl get pods -l app=$BACKEND_DEPLOYMENT -n $NAMESPACE
  
  echo
  
  print_status "Frontend Deployment Status:"
  kubectl get deployment $FRONTEND_DEPLOYMENT -n $NAMESPACE
  print_status "Frontend Pods:"
  kubectl get pods -l app=$FRONTEND_DEPLOYMENT -n $NAMESPACE
  
  echo
  
  print_status "HPA Status:"
  kubectl get hpa -n $NAMESPACE
  
  echo
  
  print_status "Services:"
  kubectl get svc -l app=deepface-backend,app=deepface-frontend -n $NAMESPACE
}

# Logs function
logs() {
  local pod_type=$1
  
  if [ -z "$pod_type" ]; then
    print_error "Usage: $0 logs [backend|frontend]"
    exit 1
  fi
  
  if [ "$pod_type" = "backend" ]; then
    print_status "Showing backend logs (follow mode)..."
    kubectl logs -f deployment/$BACKEND_DEPLOYMENT -n $NAMESPACE
  elif [ "$pod_type" = "frontend" ]; then
    print_status "Showing frontend logs (follow mode)..."
    kubectl logs -f deployment/$FRONTEND_DEPLOYMENT -n $NAMESPACE
  else
    print_error "Invalid pod type. Use 'backend' or 'frontend'"
    exit 1
  fi
}

# Scale function
scale() {
  local pod_type=$1
  local replicas=$2
  
  if [ -z "$pod_type" ] || [ -z "$replicas" ]; then
    print_error "Usage: $0 scale [backend|frontend] [replicas]"
    exit 1
  fi
  
  if [ "$pod_type" = "backend" ]; then
    print_status "Scaling backend to $replicas replicas..."
    kubectl scale deployment $BACKEND_DEPLOYMENT --replicas=$replicas -n $NAMESPACE
  elif [ "$pod_type" = "frontend" ]; then
    print_status "Scaling frontend to $replicas replicas..."
    kubectl scale deployment $FRONTEND_DEPLOYMENT --replicas=$replicas -n $NAMESPACE
  else
    print_error "Invalid pod type. Use 'backend' or 'frontend'"
    exit 1
  fi
  
  print_status "Waiting for scaling..."
  kubectl rollout status deployment/$pod_type -n $NAMESPACE --timeout=5m
}

# Update function
update() {
  local pod_type=$1
  
  if [ -z "$pod_type" ]; then
    print_error "Usage: $0 update [backend|frontend]"
    exit 1
  fi
  
  if [ "$pod_type" = "backend" ]; then
    print_status "Updating backend image..."
    kubectl set image deployment/$BACKEND_DEPLOYMENT backend=$BACKEND_IMAGE -n $NAMESPACE
  elif [ "$pod_type" = "frontend" ]; then
    print_status "Updating frontend image..."
    kubectl set image deployment/$FRONTEND_DEPLOYMENT frontend=$FRONTEND_IMAGE -n $NAMESPACE
  else
    print_error "Invalid pod type. Use 'backend' or 'frontend'"
    exit 1
  fi
  
  print_status "Waiting for rollout..."
  kubectl rollout status deployment/$pod_type -n $NAMESPACE --timeout=5m
}

# Port forward function
port_forward() {
  local pod_type=$1
  
  if [ -z "$pod_type" ]; then
    print_error "Usage: $0 port-forward [backend|frontend]"
    exit 1
  fi
  
  if [ "$pod_type" = "backend" ]; then
    print_status "Port forwarding backend service to localhost:5000..."
    kubectl port-forward svc/deepface-backend-service 5000:5000 -n $NAMESPACE
  elif [ "$pod_type" = "frontend" ]; then
    print_status "Port forwarding frontend service to localhost:3000..."
    kubectl port-forward svc/deepface-frontend-service 3000:80 -n $NAMESPACE
  else
    print_error "Invalid pod type. Use 'backend' or 'frontend'"
    exit 1
  fi
}

# Shell access function
shell() {
  local pod_type=$1
  
  if [ -z "$pod_type" ]; then
    print_error "Usage: $0 shell [backend|frontend]"
    exit 1
  fi
  
  local pod=$(kubectl get pod -l app=$pod_type -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')
  
  if [ -z "$pod" ]; then
    print_error "No pod found for $pod_type"
    exit 1
  fi
  
  print_status "Connecting to pod: $pod"
  kubectl exec -it $pod -n $NAMESPACE -- /bin/bash || kubectl exec -it $pod -n $NAMESPACE -- /bin/sh
}

# Main script
action=${1:-status}

case $action in
  deploy)
    deploy
    ;;
  delete)
    delete
    ;;
  status)
    status
    ;;
  logs)
    logs $2
    ;;
  scale)
    scale $2 $3
    ;;
  update)
    update $2
    ;;
  port-forward)
    port_forward $2
    ;;
  shell)
    shell $2
    ;;
  *)
    echo "Usage: $0 [action] [options]"
    echo ""
    echo "Actions:"
    echo "  deploy              - Deploy both frontend and backend"
    echo "  delete              - Delete deployments"
    echo "  status              - Show deployment status"
    echo "  logs [backend|frontend] - Show pod logs"
    echo "  scale [type] [replicas] - Scale deployment"
    echo "  update [backend|frontend] - Update deployment image"
    echo "  port-forward [type] - Forward pod port to localhost"
    echo "  shell [backend|frontend] - Open shell to pod"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 logs backend"
    echo "  $0 scale frontend 3"
    echo "  $0 port-forward backend"
    exit 1
    ;;
esac
