#!/bin/bash

# Get the first vote pod name
POD_NAME=$(kubectl get pods -l app=vote -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
  echo "❌ No vote pods found!"
  exit 1
fi

echo "🎯 Targeting pod: $POD_NAME"
echo "🔄 Will run a CPU-intensive loop inside the pod"
echo "⏱️ This will run for 5 minutes or until you press Ctrl+C"
echo "📊 Monitor HPA with: kubectl get hpa vote -w"

# Execute an extremely CPU-intensive loop in the pod
kubectl exec -it $POD_NAME -- bash -c '
echo "Starting CPU stress test inside pod..."
ENDTIME=$(($(date +%s) + 300))

# Launch multiple CPU-destroying processes
for i in {1..8}; do
  (
    # This creates a fork bomb effect without crashing the system
    while true; do
      # Check if we should exit
      if [ $(date +%s) -gt $ENDTIME ]; then
        break
      fi
      
      # Ultra intensive calculation with no sleep
      for j in {1..999999}; do
        x=$((j*j*j))
        y=$((x/2+x/3+x/4))
        z=$((y*y))
        a=$((z+x+y))
        b=$((a*a))
      done
    done
  ) &
done

# Wait for all processes to finish
wait
echo "Stress test completed!"
'

echo "✅ Pod stress test completed!"
echo "📈 Check your pod count with: kubectl get pods | grep vote"
echo "📊 Check your HPA status with: kubectl describe hpa vote"