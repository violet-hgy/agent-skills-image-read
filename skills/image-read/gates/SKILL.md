---
name: image-read-gates
description: 读图·环境与反幻觉。Python 仅为测量运行时；测图后端按准确可用选择，不绑定 cv2。
disable-model-invocation: true
---

# Gates

**本步未放行，禁止进入 classify / geometry / structure / visual / output，禁止写 UI，禁止用估算填像素表。**

## 定位

- **Python**：测图像素的**运行时工具**（真解释器 3.10+，绝对路径；禁止 WindowsApps 占位符），不是业务依赖。
- **测图后端**：**不强制 cv2**。Pillow、OpenCV 或其它能在该 Python 上**实测像素**的库均可。
- **选型原则**：哪个能准确开图、量宽高、采样像素，就用哪个；报告【元数据】写明实际后端。

## 放行条件

`OK|python` **且**至少一种测图后端 `OK`（如 `OK|pillow` 或 `OK|cv2`）。

Python FAIL，或**没有任何**可用测图后端 → **环境未就绪**，停止。

## 强制探测

宿主有 `env-detect` 时先跑 `measure` profile。否则：

```powershell
powershell -NoProfile -File "<本 skill 根>/scripts/probe-measure-env.ps1"
```

Unix：用真 `python3` 跑 `<本 skill 根>/scripts/probe-measure-env.py`。

```text
OK|python|<abs>|...
OK|pillow|<ver>     ← 常见默认后端（够用即可）
OK|cv2|<ver>        ← 可选；已可用或修复成功时标注，非必需
FAIL|<tool>|<reason>
```

## 失败处理（强制）

任一**当前选用**的测图手段失败时：

1. **禁止**目测估算填【像素参数表】  
2. **先自动修该手段**（对应 `pip install` 至多一次，修好立刻重试）  
3. **仍失败** → 换另一种已探测可用的后端继续实测  
4. **所有后端都不可用** → 【ImageRead环境未就绪】，停止后续 SOP  

不要绑定「必须先修 cv2 才能 Pillow」。顺序由**当前可用性与测量准确度**决定；脚本默认会确保至少 Pillow 可装可测，并顺带探测 cv2。

## 环境 FAIL → 不往下走

```text
【ImageRead环境未就绪】
- FAIL：<python 和/或 全部测图后端>
- 已自动尝试：真 Python；对各后端各至多一次 pip 修复
- 下一步：人工安装 Python 3.10+ 或设 PYTHON_EXE 后重跑探测
- 本轮禁止：classify 及之后、估算填表、写 UI
```

【暂时猜测数值占用】仅用于**已有可用测图后端**时的单字段采样不稳，不得用于「库挂了所以整表估算」。
