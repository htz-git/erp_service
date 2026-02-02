# -*- coding: utf-8 -*-
"""
LSTM 需求预测模块：根据历史销量时间序列预测未来需求量
"""
from __future__ import annotations

import numpy as np

# TensorFlow 可选：未安装时使用移动平均代替 LSTM
try:
    from tensorflow import keras
    from tensorflow.keras import layers
    HAS_TF = True
except ImportError:
    keras = None  # type: ignore[assignment]
    layers = None  # type: ignore[assignment]
    HAS_TF = False

# 序列长度（用过去多少天预测）
SEQ_LEN = 14
# 默认预测天数
DEFAULT_FORECAST_DAYS = 7
# 最小历史数据长度
MIN_HISTORY_LEN = 5


def _build_lstm_model(seq_len: int):
    """构建简单 LSTM 模型（单变量时间序列预测）"""
    model = keras.Sequential([
        layers.LSTM(32, activation='relu', input_shape=(seq_len, 1), return_sequences=False),
        layers.Dense(16, activation='relu'),
        layers.Dense(1)
    ])
    model.compile(optimizer='adam', loss='mse')
    return model


def _prepare_sequences(values: list, seq_len: int):
    """将时间序列转为 LSTM 输入 (samples, seq_len, 1) 与标签"""
    values = np.array(values, dtype=np.float64).reshape(-1, 1)
    if len(values) < seq_len + 1:
        return None, None
    X, y = [], []
    for i in range(len(values) - seq_len):
        X.append(values[i:i + seq_len])
        y.append(values[i + seq_len, 0])
    return np.array(X), np.array(y)


def predict_with_lstm(values: list, forecast_days: int = DEFAULT_FORECAST_DAYS) -> list:
    """
    使用 LSTM 预测未来 forecast_days 天的每日销量
    :param values: 历史每日销量列表（按时间升序）
    :param forecast_days: 预测天数
    :return: 预测的每日销量列表，长度 forecast_days
    """
    if not values or len(values) < MIN_HISTORY_LEN:
        # 数据不足时退回简单均值
        avg = float(np.mean(values)) if values else 0.0
        return [max(0, round(avg))] * forecast_days

    values = [float(v) for v in values]
    seq_len = min(SEQ_LEN, len(values) - 1)
    if seq_len < 2:
        avg = float(np.mean(values))
        return [max(0, round(avg))] * forecast_days

    if not HAS_TF:
        # 无 TensorFlow 时使用移动平均
        window = min(7, len(values))
        avg = float(np.mean(values[-window:]))
        return [max(0, round(avg))] * forecast_days

    X, y = _prepare_sequences(values, seq_len)
    if X is None or len(X) < 2:
        avg = float(np.mean(values))
        return [max(0, round(avg))] * forecast_days

    model = _build_lstm_model(seq_len)
    model.fit(X, y, epochs=20, batch_size=min(8, len(X)), verbose=0)

    # 自回归预测未来 forecast_days 天
    last_seq = list(values[-seq_len:])
    predictions = []
    for _ in range(forecast_days):
        x = np.array(last_seq[-seq_len:], dtype=np.float64).reshape(1, seq_len, 1)
        pred = model.predict(x, verbose=0)[0, 0]
        pred = max(0.0, float(pred))
        predictions.append(round(pred, 2))
        last_seq.append(pred)
    return predictions


def predict_simple_fallback(values: list, forecast_days: int = DEFAULT_FORECAST_DAYS) -> list:
    """无 LSTM 时的简单预测：近期移动平均"""
    if not values:
        return [0] * forecast_days
    values = [float(v) for v in values]
    window = min(14, len(values))
    avg = float(np.mean(values[-window:]))
    return [max(0, round(avg))] * forecast_days
