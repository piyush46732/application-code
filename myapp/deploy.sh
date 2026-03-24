#!/bin/bash
set -e

APP_NAME="myapp"
IMAGE="piyush8398/$APP_NAME"
TAG=$1
STABLE_TAG="stable"

USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "Disk usage: $USAGE%"

if [ "$USAGE" -lt 50 ]; then
  echo "✅ Deploying new image..."
  docker pull $IMAGE:$TAG
  docker stop $APP_NAME || true
  docker rm $APP_NAME || true
  docker run -d --name $APP_NAME -p 80:3000 $IMAGE:$TAG
  docker tag $IMAGE:$TAG $IMAGE:$STABLE_TAG
  docker push $IMAGE:$STABLE_TAG
else
  echo "❌ Disk usage too high, rolling back..."
  docker stop $APP_NAME || true
  docker rm $APP_NAME || true
  docker run -d --name $APP_NAME -p 80:3000 $IMAGE:$STABLE_TAG
fi
