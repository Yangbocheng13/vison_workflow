#!/usr/bin/env bash
set -euo pipefail

DETECT_DIR="${DETECT_DIR:-/root/detect}"
MODEL_PATH="${MODEL_PATH:-${DETECT_DIR}/yolov8n-pose_bayese_640x640_nv12.bin}"
IMAGE_TOPIC="${IMAGE_TOPIC:-/camera/image_raw}"
RESULT_TOPIC="${RESULT_TOPIC:-/person_pose/result_image}"
CONFIG_PATH="${CONFIG_PATH:-${DETECT_DIR}/rdk_pose_runtime.yaml}"

SCORE_THRES="${SCORE_THRES:-0.35}"
NMS_THRES="${NMS_THRES:-0.50}"
KPT_CONF_THRES="${KPT_CONF_THRES:-0.60}"

CAMERA_LOG="${CAMERA_LOG:-${DETECT_DIR}/camera.log}"
POSE_LOG="${POSE_LOG:-${DETECT_DIR}/pose.log}"

CAMERA_PID=""
POSE_PID=""

cleanup() {
  if [[ -n "${POSE_PID}" ]] && kill -0 "${POSE_PID}" 2>/dev/null; then
    kill "${POSE_PID}" 2>/dev/null || true
  fi
  if [[ -n "${CAMERA_PID}" ]] && kill -0 "${CAMERA_PID}" 2>/dev/null; then
    kill "${CAMERA_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

cd "${DETECT_DIR}"
set +u
source /opt/ros/humble/setup.bash
set -u

export LD_LIBRARY_PATH=/opt/MVS/lib/aarch64:${LD_LIBRARY_PATH:-}
export PYTHONPATH=/opt/MVS/Samples/aarch64/Python/MvImport:${PYTHONPATH:-}

if [[ ! -f "${MODEL_PATH}" ]]; then
  echo "Model not found: ${MODEL_PATH}" >&2
  exit 1
fi

echo "Starting Hikrobot camera node..."
python3 -u "${DETECT_DIR}/hik_camera_publisher.py" >"${CAMERA_LOG}" 2>&1 &
CAMERA_PID=$!

sleep 3
if ! kill -0 "${CAMERA_PID}" 2>/dev/null; then
  echo "Camera node exited. Check ${CAMERA_LOG}" >&2
  exit 1
fi

echo "Starting official YOLOv8 pose node..."
if [[ -f "${CONFIG_PATH}" ]]; then
  python3 -u "${DETECT_DIR}/person_pose_node_official.py" \
    --config "${CONFIG_PATH}" >"${POSE_LOG}" 2>&1 &
else
  python3 -u "${DETECT_DIR}/person_pose_node_official.py" \
    --model "${MODEL_PATH}" \
    --image-topic "${IMAGE_TOPIC}" \
    --result-topic "${RESULT_TOPIC}" \
    --score-thres "${SCORE_THRES}" \
    --nms-thres "${NMS_THRES}" \
    --kpt-conf-thres "${KPT_CONF_THRES}" \
    --debug-output >"${POSE_LOG}" 2>&1 &
fi
POSE_PID=$!

echo "Pipeline started."
echo "Camera log: ${CAMERA_LOG}"
echo "Pose log:   ${POSE_LOG}"
echo "Image topic:  ${IMAGE_TOPIC}"
echo "Result topic: ${RESULT_TOPIC}"
echo "Press Ctrl+C to stop both nodes."

wait "${POSE_PID}"
