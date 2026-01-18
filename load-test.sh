#!/bin/bash

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Deepface Autoscaling Load Test${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to display menu
show_menu() {
    echo -e "${YELLOW}Choose what to test:${NC}"
    echo "1. Frontend Autoscaling Test"
    echo "2. Backend Autoscaling Test"
    echo "3. Both (Frontend + Backend)"
    echo "4. Light Load (Gentle test)"
    echo "5. Heavy Load (Aggressive stress test)"
    echo "6. Watch HPA Status"
    echo "7. Stop all load tests"
    echo "8. Exit"
    echo ""
}

# Function to start frontend load test
load_frontend() {
    echo -e "${GREEN}[*] Deploying Frontend Load Test...${NC}"
    kubectl apply -f load-test-frontend.yaml
    echo -e "${GREEN}[✓] Frontend load test started${NC}"
    echo ""
}

# Function to start backend load test
load_backend() {
    echo -e "${GREEN}[*] Deploying Backend Load Test...${NC}"
    kubectl apply -f load-test-backend.yaml
    echo -e "${GREEN}[✓] Backend load test started${NC}"
    echo ""
}

# Function for light load
light_load() {
    echo -e "${GREEN}[*] Starting Light Load Test (1 request/sec for 3 min)...${NC}"
    kubectl run -it load-light --image=curlimages/curl --restart=Never -- sh -c \
    "for i in {1..180}; do 
      curl -s http://deepface-frontend-service/ > /dev/null &
      [ \$((i % 30)) -eq 0 ] && echo \"[\$(date +'%H:%M:%S')] Sent \$i requests...\"
      sleep 1
    done; echo 'Light load test done!'"
    echo ""
}

# Function for heavy load
heavy_load() {
    echo -e "${YELLOW}[!] Starting Heavy Load Test (10 concurrent requests/sec for 5 min)...${NC}"
    echo -e "${YELLOW}[!] Warning: This will aggressively scale your deployment!${NC}"
    kubectl run -it load-heavy --image=curlimages/curl --restart=Never -- sh -c \
    "for i in {1..300}; do 
      for j in {1..10}; do
        curl -s http://deepface-frontend-service/ > /dev/null &
      done
      [ \$((i % 30)) -eq 0 ] && echo \"[\$(date +'%H:%M:%S')] Sent \$((i*10)) requests...\"
      sleep 1
    done; echo 'Heavy load test done!'"
    echo ""
}

# Function to watch HPA
watch_hpa() {
    echo -e "${GREEN}[*] Watching HPA Status (Press Ctrl+C to stop)...${NC}"
    echo ""
    kubectl get hpa -A --watch
}

# Function to stop load tests
stop_tests() {
    echo -e "${YELLOW}[*] Stopping all load test pods...${NC}"
    kubectl delete pod load-test-frontend load-test-backend load-light load-heavy --ignore-not-found=true
    echo -e "${GREEN}[✓] All load tests stopped${NC}"
    echo ""
}

# Function to show HPA status
show_hpa_status() {
    echo -e "${GREEN}Current HPA Status:${NC}"
    kubectl get hpa -A
    echo ""
    echo -e "${GREEN}Backend HPA Details:${NC}"
    kubectl describe hpa deepface-backend-hpa
    echo ""
    echo -e "${GREEN}Frontend HPA Details:${NC}"
    kubectl describe hpa deepface-frontend-hpa
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (1-8): " choice
    echo ""
    
    case $choice in
        1)
            load_frontend
            ;;
        2)
            load_backend
            ;;
        3)
            load_frontend
            load_backend
            ;;
        4)
            light_load
            ;;
        5)
            heavy_load
            ;;
        6)
            watch_hpa
            ;;
        7)
            stop_tests
            ;;
        8)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid choice! Please try again.${NC}"
            echo ""
            ;;
    esac
done
