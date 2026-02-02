# -*- coding: utf-8 -*-
"""
LSTM 补货预测服务：提供 REST API，接收销售时序，返回预测需求量
供 erp-list-replenishment-service 通过 HTTP 调用
"""
from __future__ import annotations

import os
import sys

# 保证无论从何目录运行，都能正确导入同目录下的 predictor 模块
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

try:
    from flask import Flask, request, jsonify
except ImportError:
    raise ImportError("请先安装依赖: cd lstm-forecast-service && pip install -r requirements.txt")

from predictor import predict_with_lstm, DEFAULT_FORECAST_DAYS

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "UP"})


@app.route("/predict", methods=["POST"])
def predict():
    """
    请求体示例:
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
    响应示例:
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
    """
    try:
        body = request.get_json() or {}
        series = body.get("series", [])
        forecast_days = int(body.get("forecastDays", DEFAULT_FORECAST_DAYS))
        forecast_days = max(1, min(forecast_days, 30))

        predictions = []
        for item in series:
            sku_id = item.get("skuId")
            sku_code = item.get("skuCode", "")
            product_name = item.get("productName", "")
            product_id = item.get("productId")
            values = item.get("values", [])
            if not values:
                forecast_daily = [0] * forecast_days
            else:
                forecast_daily = predict_with_lstm(values, forecast_days)
            forecast_total = sum(forecast_daily)
            predictions.append({
                "skuId": sku_id,
                "skuCode": sku_code,
                "productName": product_name,
                "productId": product_id,
                "forecastTotal": int(forecast_total),
                "forecastDaily": forecast_daily,
            })
        return jsonify({"predictions": predictions})
    except Exception as e:
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
