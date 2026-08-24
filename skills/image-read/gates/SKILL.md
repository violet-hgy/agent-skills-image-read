---
name: gates
description: 读图·环境与反幻觉（由 image-read 调度）。先自动修 cv2；修不好再用 Pillow。两者皆失败则停止。
disable-model-invocation: true
metadata:
  internal: "true"
---

# Gates

**本步未放行，禁止进入 classify / geometry / structure / visual / output，禁止写 UI，禁止用估算填像素表。**

## 测量栈（优先顺序）

| 优先级 | 项 | 要求 |
| --- | --- | --- |
| 0 | Python | 3.10+ **真解释器**（绝对路径；禁止 `WindowsApps` 占位符） |
| 1 | `cv2`（OpenCV） | **优先**测图后端。失败必须先自动修，禁止立刻改估算 |
| 2 | Pillow | **仅当 cv2 自动修复仍失败**后的实测后端 |

放行条件：`OK|python` **且**（`OK|cv2` **或** `OK|pillow`）。  
Python FAIL，或 cv2 与 Pillow **都** FAIL → **环境未就绪**，停止。

## 强制探测

宿主有 `env-detect` 时先跑其 `measure` profile。否则：

```powershell
powershell -NoProfile -File "<本 skill 根>/scripts/probe-measure-env.ps1"
```

Unix：用已解析的真 `python3` 跑 `<本 skill 根>/scripts/probe-measure-env.py`。

```text
OK|python|<abs>|...
OK|cv2|<ver>          ← 有则优先用 cv2 测
OK|pillow|<ver>       ← cv2 不可用时必须有
FAIL|<tool>|<reason>
```

## 失败处理顺序（强制）

出现 `cv2` / `No module named cv2` / `DLL load failed` / 崩溃等：

1. **禁止**目测估算填【像素参数表】  
2. **先自动修 cv2**（每步最多一次，修完立刻重测 `import cv2`）  
   - `pip install opencv-python`  
   - 仍失败（常见 DLL）：`pip install opencv-python-headless`  
3. **仍失败 → 再用 Pillow 实测**（缺则 `pip install Pillow` 一次）  
4. cv2 与 Pillow **都**失败 → 【ImageRead环境未就绪】，停止后续 SOP  

禁止：一报错就跳过修复、改用猜测、或没试修 cv2 就直接 Pillow（脚本会按上序做；Agent 手测时同样必须先修 cv2）。

## 环境 FAIL → 不往下走

只输出：

```text
【ImageRead环境未就绪】
- FAIL：<python / cv2 / pillow>
- 已自动尝试：真 Python 路径；opencv-python；opencv-python-headless；Pillow（各至多一次）
- 下一步：人工安装 Python 3.10+ 或设 PYTHON_EXE 后重跑探测
- 本轮禁止：classify 及之后、估算填表、写 UI
```

**禁止**在 FAIL 后继续 geometry/visual「先估个数」、用猜测凑完整报告、写 UI。

【暂时猜测数值占用】仅用于**已有 cv2 或 Pillow 实测能力**时的单字段采样不稳，不得用于「库挂了所以整表估算」。
