# 文件清单

## ROS2 视觉包

- `ros2_ws_src/farr_vision_bpu/package.xml`
- `ros2_ws_src/farr_vision_bpu/setup.py`
- `ros2_ws_src/farr_vision_bpu/setup.cfg`
- `ros2_ws_src/farr_vision_bpu/resource/farr_vision_bpu`
- `ros2_ws_src/farr_vision_bpu/farr_vision_bpu/__init__.py`
- `ros2_ws_src/farr_vision_bpu/farr_vision_bpu/hik_camera_publisher.py`
- `ros2_ws_src/farr_vision_bpu/farr_vision_bpu/person_pose_node_official.py`
- `ros2_ws_src/farr_vision_bpu/farr_vision_bpu/save_pose_result.py`

## Bringup 配置

- `farr_bringup/launch/vision.launch.py`
- `farr_bringup/launch/competition.launch.py`
- `farr_bringup/config/rdk_pose_runtime.yaml`

## 模型

- `models/yolo/yolov8n-pose_bayese_640x640_nv12.bin`

## 历史 detect 目录

- `legacy_detect/detect/hik_camera_publisher.py`
- `legacy_detect/detect/person_pose_node_official.py`
- `legacy_detect/detect/save_pose_result.py`
- `legacy_detect/detect/start_rdk_pose_pipeline.sh`
- `legacy_detect/detect/stop_rdk_pose_pipeline.sh`
- `legacy_detect/detect/rdk_pose_runtime.yaml`
- `legacy_detect/detect/yolov8n-pose_bayese_640x640_nv12.bin`
- `legacy_detect/detect/person_pose_result.jpg`
- `legacy_detect/detect/camera.log`
- `legacy_detect/detect/pose.log`
