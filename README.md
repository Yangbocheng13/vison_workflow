# RDK X5 视觉工作流项目整理

本目录从 RDK X5 `192.168.140.233` 拉取并整理，用于查看、备份和继续开发 FARR 机器人视觉推理链路。

## 来源

- 远端主工作区：`/root/farr_robot_ws`
- 视觉 ROS2 包：`/root/farr_robot_ws/src/farr_vision_bpu`
- 视觉启动文件：`/root/farr_robot_ws/src/farr_bringup/launch/vision.launch.py`
- 视觉运行配置：`/root/farr_robot_ws/src/farr_bringup/config/rdk_pose_runtime.yaml`
- BPU 模型：`/root/models/yolo/yolov8n-pose_bayese_640x640_nv12.bin`
- 历史单文件调试目录：`/root/detect`

## 本地目录结构

```text
/home/y/rdkx5_vision_workflow/
  README.md
  FILE_MANIFEST.md
  ros2_ws_src/
    farr_vision_bpu/             # ROS2 视觉包，可放回工作区 src 下构建
  farr_bringup/
    launch/
      vision.launch.py           # 相机 + YOLO BPU 推理启动文件
      competition.launch.py      # 比赛模式启动文件副本
    config/
      rdk_pose_runtime.yaml      # YOLO pose 运行参数
  models/
    yolo/
      yolov8n-pose_bayese_640x640_nv12.bin
  legacy_detect/
    detect/                      # /root/detect 历史脚本、日志、样例输出
```

## 工作流

视觉链路由两个 ROS2 节点组成：

1. `hik_camera_publisher`
   - 读取海康 USB 相机。
   - 发布原始图像到 `/camera/image_raw`。
   - 依赖海康 MVS SDK：`/opt/MVS/Samples/aarch64/Python/MvImport`。

2. `person_pose_node`
   - 订阅 `/camera/image_raw`。
   - 加载 RDK X5 BPU YOLOv8 pose 模型。
   - 发布绘制后的结果图像到 `/person_pose/result_image`。
   - 默认还发布检测 JSON 到 `/person_pose/detections`，状态到 `/person_pose/status`。

保存单帧结果使用 `save_pose_result`：

- 订阅：`/person_pose/result_image`
- 输出：`/root/detect/person_pose_result.jpg`
- 收到第一帧后自动退出

## 在 RDK X5 上运行

```bash
ssh root@192.168.140.233
cd /root/farr_robot_ws
source /opt/ros/humble/setup.bash
./fix_farr_env.sh
source install/setup.bash
ros2 launch farr_bringup vision.launch.py
```

另开一个 SSH 终端检查话题：

```bash
source /opt/ros/humble/setup.bash
source /root/farr_robot_ws/install/setup.bash
ros2 topic hz /camera/image_raw
ros2 topic hz /person_pose/result_image
```

## 保存一帧推理图像

视觉 launch 正在运行时，另开 SSH 终端：

```bash
ssh root@192.168.140.233
cd /root/farr_robot_ws
source /opt/ros/humble/setup.bash
./fix_farr_env.sh
source install/setup.bash
mkdir -p /root/detect
ros2 run farr_vision_bpu save_pose_result
```

保存成功后输出文件：

```text
/root/detect/person_pose_result.jpg
```

拉回主机查看：

```bash
scp root@192.168.140.233:/root/detect/person_pose_result.jpg /home/y/rdkx5_vision_workflow/person_pose_result_latest.jpg
xdg-open /home/y/rdkx5_vision_workflow/person_pose_result_latest.jpg
```

## 关键配置

配置文件：`farr_bringup/config/rdk_pose_runtime.yaml`

```yaml
model: /root/models/yolo/yolov8n-pose_bayese_640x640_nv12.bin
image_topic: /camera/image_raw
result_topic: /person_pose/result_image
score_thres: 0.35
nms_thres: 0.50
kpt_conf_thres: 0.60
resize_type: 1
input_size: 640
max_detections: 50
debug_output: true
```

调参优先改：

- `score_thres`：越高误检越少，但可能漏人。
- `nms_thres`：越低越容易压掉重复框。
- `kpt_conf_thres`：越高绘制的关键点越少但更可靠。

## 文件说明

- `hik_camera_publisher.py`：海康相机采集并发布 ROS2 Image。
- `person_pose_node_official.py`：YOLOv8 pose BPU 推理、后处理、绘制和发布。
- `save_pose_result.py`：保存一帧推理结果图。
- `vision.launch.py`：设置 MVS 环境变量并启动相机节点和推理节点。
- `legacy_detect/detect/person_pose_result.jpg`：远端已有样例输出图。

## 重新同步

如果 RDK X5 上代码有新变化，可以重新执行拉取流程，目标仍然放到：

```text
/home/y/rdkx5_vision_workflow
```

注意不要直接覆盖本地改动；如果本地已经继续开发，先做备份或用 `diff` 对比。
