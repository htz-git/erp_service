# LSTM 补货预测服务

基于 LSTM 对订单销售时序进行需求预测，供补货服务（erp-list-replenishment-service）通过 HTTP 调用以生成补货建议。

## 依赖

- **Python 3.8+**（推荐 3.9，与 TensorFlow 兼容较好）
- `requirements.txt`：Flask、NumPy 必选；TensorFlow 可选（未安装时自动退化为移动平均预测）

## 消除 IDE 中 Python 导入报错

项目以 Java 为主，未配置 Python 解释器时，Cursor/VS Code 会对本目录下的 `flask`、`numpy` 等报「未解析的导入」。按下面做即可消除：

1. **在本目录创建并激活虚拟环境**（见下方「运行」）。
2. **在 IDE 中选择该解释器**：  
   `Ctrl+Shift+P`（Mac：`Cmd+Shift+P`）→ **「Python: Select Interpreter」** → 选择：
   - **Windows**：`lstm-forecast-service\venv\Scripts\python.exe`
   - **Mac/Linux**：`lstm-forecast-service/venv/bin/python`
3. （可选）将仓库根目录下的 `vscode-settings-example.json` 内容复制到 `.vscode/settings.json`，使 workspace 默认使用上述解释器（Windows 路径；Mac/Linux 请将 `Scripts/python.exe` 改为 `bin/python`）。

本目录下的 `pyproject.toml` 用于让 IDE 识别 Python 版本与虚拟环境路径。

## 运行

**推荐：在本目录下使用虚拟环境**

```bash
cd lstm-forecast-service
python -m venv venv
# Windows:
venv\Scripts\activate
# Mac/Linux:
# source venv/bin/activate
pip install -r requirements.txt
python app.py
```

也可从仓库根目录运行（脚本已把本目录加入 `sys.path`，可正确导入 `predictor`）：

```bash
python lstm-forecast-service/app.py
```

默认端口 **5000**，可通过环境变量 `PORT` 修改。

## API

- `GET /health`：健康检查
- `POST /predict`：预测

### POST /predict

**请求体：**

```json
{
  "series": [
    {
      "skuId": 1,
      "skuCode": "SKU001",
      "productName": "商品A",
      "productId": 100,
      "values": [10, 12, 11, 15, 13, 14, 12, 11, 16, 14, 13, 15, 12, 14]
    }
  ],
  "forecastDays": 7
}
```

- `series`：每个 SKU 的历史每日销量序列（`values` 按日期升序）
- `forecastDays`：预测未来天数，默认 7，最大 30

**响应：**

```json
{
  "predictions": [
    {
      "skuId": 1,
      "skuCode": "SKU001",
      "productName": "商品A",
      "productId": 100,
      "forecastTotal": 91,
      "forecastDaily": [13, 13, 13, 13, 13, 13, 13]
    }
  ]
}
```

## 与补货服务集成

补货服务通过配置 `lstm.forecast.service-url`（如 `http://localhost:5000`）调用本服务。  
若不启动本服务，补货建议接口 `GET /replenishments/suggestions` 会返回空列表。
