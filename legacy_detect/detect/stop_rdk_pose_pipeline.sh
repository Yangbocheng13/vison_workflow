#!/usr/bin/env bash
set -euo pipefail

pkill -f hik_camera_publisher.py || true
pkill -f person_pose_node_official.py || true

echo "Stopped camera and pose nodes."
