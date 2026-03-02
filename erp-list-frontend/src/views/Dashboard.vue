<template>
  <div class="dashboard">
    <!-- 模块一：初始化引导（可收起/展开、可隐藏整块） -->
    <div v-show="!guideSectionHidden" class="dashboard-section">
      <el-card class="section-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>初始化引导</span>
            <div class="card-header-actions">
              <el-button type="primary" link @click="toggleGuideCollapsed">
                {{ guideCollapsed ? '展开' : '收起' }}
              </el-button>
              <el-button type="info" link @click="hideGuideSection">隐藏本模块</el-button>
            </div>
          </div>
        </template>
        <div v-show="!guideCollapsed" class="guide-steps">
          <div v-for="(step, i) in guideSteps" :key="i" class="guide-step">
            <div class="step-icon">
              <el-icon v-if="step.icon" :size="28"><component :is="step.icon" /></el-icon>
              <span v-else class="step-check">√</span>
            </div>
            <div class="step-content">
              <div class="step-title">
                {{ step.title }}
                <el-tag v-if="step.required" size="small" type="danger">必做</el-tag>
              </div>
              <div class="step-desc">{{ step.desc }}</div>
              <router-link v-if="step.link" :to="step.link" class="step-link">
                {{ step.linkText || '前往' }}
              </router-link>
            </div>
          </div>
        </div>
      </el-card>
    </div>
    <!-- 初始化引导已隐藏时，提供入口重新显示（也可通过顶栏「初始化引导」下拉控制） -->
    <div v-if="guideSectionHidden" class="dashboard-section guide-restore-bar">
      <el-button type="primary" link @click="showGuideSection">
        <el-icon><Expand /></el-icon>
        显示初始化引导
      </el-button>
    </div>

    <!-- 订单趋势 -->
    <div class="dashboard-section">
      <el-card class="section-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>订单趋势</span>
            <div class="card-header-right">
              <span class="range-label">时间范围</span>
              <el-date-picker
                v-model="trendDateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                value-format="YYYY-MM-DD"
                size="default"
                class="trend-date-picker"
              />
              <el-button type="primary" size="default" :loading="trendLoading" :disabled="!trendDateRange || trendDateRange.length !== 2" @click="loadTrendData">查询</el-button>
            </div>
          </div>
        </template>
        <div class="trend-summary">
          选定时间范围内订单数：<strong class="trend-total">{{ trendLoading ? '加载中...' : rangeOrderTotal }}</strong>
        </div>
        <div ref="trendRef" class="trend-chart"></div>
      </el-card>
    </div>

    <!-- 订单分布 -->
    <div class="dashboard-section">
      <el-card class="section-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span>订单分布</span>
            <div class="card-header-right">
              <span class="date-range">{{ orderDateRange }} 数据</span>
              <el-radio-group v-model="orderType" size="small">
                <el-radio-button label="sale">销售</el-radio-button>
                <el-radio-button label="refund">退货</el-radio-button>
              </el-radio-group>
              <el-radio-group v-model="orderPeriod" size="small">
                <el-radio-button label="7">前7天</el-radio-button>
                <el-radio-button label="14">前14天</el-radio-button>
                <el-radio-button label="28">前28天</el-radio-button>
              </el-radio-group>
            </div>
          </div>
        </template>
        <div ref="mapRef" class="order-map-chart"></div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/store/user'
import { useDashboardStore } from '@/store/dashboard'
import * as echarts from 'echarts'
import worldJson from '@/assets/geo/world.json'
import { orderApi } from '@/api/order'
import {
  Key,
  Plus,
  Connection,
  MoreFilled,
  Expand
} from '@element-plus/icons-vue'

const userStore = useUserStore()
const dashboardStore = useDashboardStore()
const { guideCollapsed, guideSectionHidden } = storeToRefs(dashboardStore)
const { toggleGuideCollapsed, hideGuideSection, showGuideSection } = dashboardStore

const currentUser = computed(() => userStore.currentUser())

const guideSteps = [
  {
    title: '基础数据授权',
    desc: '授权店铺客服邮箱等信息，开启数字化管理。',
    icon: Key,
    required: true,
    link: '/user/create',
    linkText: '去创建用户'
  },
  {
    title: '产品信息维护',
    desc: '录入本地产品并配对平台商品，实现数据匹配。',
    icon: Plus,
    required: false
  },
  {
    title: '供应链管理',
    desc: '各关键环节于一体，高效管理。',
    icon: Connection,
    required: false
  },
  {
    title: '更多进阶功能',
    desc: '智能补货建议、业财一体化管理等亮点功能。',
    icon: MoreFilled,
    required: false
  }
]

const orderDateRange = ref('')
const orderType = ref('sale')
const orderPeriod = ref('28')

function getDefaultTrendRange() {
  const end = new Date()
  const start = new Date()
  start.setDate(start.getDate() - 6)
  return [start.toISOString().slice(0, 10), end.toISOString().slice(0, 10)]
}
const trendDateRange = ref(getDefaultTrendRange())
const rangeOrderTotal = ref('-')
const trendRef = ref(null)
let trendChart = null
const trendLoading = ref(false)

// 国家代码 -> [经度, 纬度]，与后端 COUNTRY_NAME_MAP 对应
const COUNTRY_COORDS = {
  US: [-95.7129, 37.0902],
  DE: [10.4515, 51.1657],
  UK: [-3.436, 55.3781],
  FR: [2.2137, 46.2276],
  IT: [12.5674, 41.8719],
  ES: [-3.7492, 40.4637],
  JP: [138.2529, 36.2048],
  CA: [-106.3468, 56.1304],
  AU: [133.7751, -25.2744],
  IN: [78.9629, 20.5937],
  MX: [-102.5528, 23.6345],
  BR: [-51.9253, -14.235],
  NL: [5.2913, 52.1326],
  PL: [19.1451, 51.9194],
  TR: [35.2433, 38.9637],
  CN: [104.1954, 35.8617],
  KR: [127.7669, 35.9078],
  SG: [103.8198, 1.3521],
  AE: [53.8478, 23.4241],
  SA: [45.0792, 23.8859]
}

const mapRef = ref(null)
let mapChart = null
let resizeHandler = null
const mapLoading = ref(false)

function getDateRangeByPeriod(days) {
  const end = new Date()
  const start = new Date()
  start.setDate(start.getDate() - parseInt(days, 10))
  return {
    startDate: start.toISOString().slice(0, 10),
    endDate: end.toISOString().slice(0, 10)
  }
}

async function fetchRangeTotal(startDate, endDate) {
  const user = currentUser.value
  const params = { pageNum: 1, pageSize: 1, createTimeStart: startDate, createTimeEnd: endDate }
  if (user?.zid) params.zid = user.zid
  if (user?.sid != null) params.sid = user.sid
  try {
    const res = await orderApi.queryOrders(params)
    rangeOrderTotal.value = res?.data?.total ?? 0
  } catch {
    rangeOrderTotal.value = '-'
  }
}

async function fetchTrendData() {
  const range = trendDateRange.value
  if (!range || range.length !== 2) {
    setTrendOption([], [])
    return
  }
  const [startDate, endDate] = range
  const user = currentUser.value
  const params = { pageNum: 1, pageSize: 1 }
  if (user?.zid) params.zid = user.zid
  if (user?.sid != null) params.sid = user.sid
  const labels = []
  const values = []
  const start = new Date(startDate)
  const end = new Date(endDate)
  trendLoading.value = true
  try {
    await fetchRangeTotal(startDate, endDate)
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const dayStr = d.toISOString().slice(0, 10)
      labels.push(dayStr.slice(5))
      const res = await orderApi.queryOrders({
        ...params,
        createTimeStart: dayStr,
        createTimeEnd: dayStr
      })
      values.push(res?.data?.total ?? 0)
    }
    setTrendOption(labels, values)
  } catch {
    rangeOrderTotal.value = '-'
    setTrendOption([], [])
  } finally {
    trendLoading.value = false
  }
}

async function loadTrendData() {
  if (!trendDateRange.value || trendDateRange.value.length !== 2) return
  await fetchTrendData()
}

function setTrendOption(labels, values) {
  if (!trendChart) return
  trendChart.setOption({
    xAxis: { type: 'category', data: labels, boundaryGap: false },
    yAxis: { type: 'value', minInterval: 1 },
    series: [{ name: '订单数', type: 'line', data: values, smooth: true, areaStyle: { opacity: 0.2 } }],
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '10%', containLabel: true }
  })
}

function initTrendChart() {
  if (!trendRef.value) return
  trendChart = echarts.init(trendRef.value)
  trendChart.setOption({
    xAxis: { type: 'category', boundaryGap: false },
    yAxis: { type: 'value', minInterval: 1 },
    series: [{ name: '订单数', type: 'line', smooth: true, areaStyle: { opacity: 0.2 } }],
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '10%', containLabel: true }
  })
  setTrendOption([], [])
  window.addEventListener('resize', () => trendChart?.resize())
}

async function fetchMapData() {
  const { startDate, endDate } = getDateRangeByPeriod(orderPeriod.value)
  orderDateRange.value = `${startDate} ~ ${endDate}`
  const user = currentUser.value
  const params = { startDate, endDate }
  if (user?.zid) params.zid = user.zid
  if (user?.sid != null) params.sid = user.sid
  mapLoading.value = true
  try {
    const res = await orderApi.getOrderStatsByCountry(params)
    const list = res?.data ?? []
    const scatterData = list
      .filter((item) => item.countryCode && COUNTRY_COORDS[item.countryCode.toUpperCase()])
      .map((item) => {
        const code = item.countryCode.toUpperCase()
        const coords = COUNTRY_COORDS[code]
        const name = item.countryName || item.countryCode
        const count = item.orderCount ?? 0
        return { name, value: [coords[0], coords[1], count] }
      })
    return scatterData
  } finally {
    mapLoading.value = false
  }
}

function setMapSeriesData(scatterData) {
  if (!mapChart) return
  mapChart.setOption({
    series: [{ data: scatterData }]
  })
}

function initOrderMap() {
  if (!mapRef.value) return
  try {
    echarts.registerMap('world', worldJson)
    mapChart = echarts.init(mapRef.value)
    const option = {
      tooltip: {
        trigger: 'item',
        formatter: (params) => {
          const d = params.data
          if (d?.value && d.value[2] != null) {
            return `${d.name}<br/>订单数: ${d.value[2]}`
          }
          return params.name || ''
        }
      },
      geo: {
        map: 'world',
        roam: true,
        itemStyle: {
          areaColor: '#f3f3f3',
          borderColor: '#ccc'
        },
        emphasis: {
          itemStyle: { areaColor: '#e0e8f0' },
          label: { show: false }
        }
      },
      series: [
        {
          name: '订单分布',
          type: 'scatter',
          coordinateSystem: 'geo',
          data: [],
          symbolSize: (val) => {
            const v = val[2] || 10
            return Math.max(10, Math.min(28, v / 6))
          },
          itemStyle: {
            color: 'var(--primary-color, #409eff)',
            borderColor: '#fff',
            borderWidth: 1
          },
          emphasis: {
            scale: 1.2,
            itemStyle: { borderWidth: 2 }
          }
        }
      ]
    }
    mapChart.setOption(option)
    resizeHandler = () => mapChart?.resize()
    window.addEventListener('resize', resizeHandler)
    nextTick(() => mapChart?.resize())
  } catch (e) {
    console.error('订单分布地图加载失败', e)
    if (mapRef.value) {
      mapRef.value.innerHTML =
        '<div class="order-map-fallback">地图数据加载失败，请检查网络或稍后重试</div>'
    }
  }
}

async function loadMapData() {
  const scatterData = await fetchMapData()
  setMapSeriesData(scatterData)
}

onMounted(async () => {
  initTrendChart()
  await loadTrendData()
  initOrderMap()
  await loadMapData()
})

onUnmounted(() => {
  if (resizeHandler) {
    window.removeEventListener('resize', resizeHandler)
  }
  mapChart?.dispose()
  mapChart = null
  trendChart?.dispose()
  trendChart = null
})

watch([orderType, orderPeriod], () => {
  loadMapData()
})
</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  gap: var(--section-gap);
}

.dashboard-section {
  width: 100%;
}

.section-card {
  border-radius: var(--card-radius);
  box-shadow: var(--card-shadow);
}

.section-card:hover {
  box-shadow: var(--card-shadow-hover);
}

.section-card :deep(.el-card__header) {
  padding: 14px 20px;
  border-bottom: 1px solid var(--header-border);
}

.section-card :deep(.el-card__body) {
  padding: 20px;
}

.card-header-right { flex-wrap: wrap; }
.trend-date-picker { margin-right: 8px; min-width: 220px; }
.range-label { margin-right: 8px; color: var(--el-text-color-regular); font-size: 14px; white-space: nowrap; }
.trend-summary { margin-bottom: 16px; font-size: 15px; color: var(--el-text-color-regular); }
.trend-total { color: var(--el-color-primary); font-size: 18px; margin-left: 4px; }
.trend-chart { height: 280px; width: 100%; }

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}

.card-header-right,
.card-header-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 13px;
  color: var(--text-secondary);
  font-weight: normal;
}

/* 初始化引导 */
.guide-steps {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: var(--card-gap);
}

.guide-step {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 12px;
  border-radius: var(--card-radius);
  background: var(--main-bg);
  border: 1px solid var(--header-border);
}

.step-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--primary-color);
  color: #fff;
  border-radius: 8px;
  margin-bottom: 8px;
}

.step-check {
  font-size: 18px;
  font-weight: bold;
}

.step-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.step-desc {
  font-size: 12px;
  color: var(--text-secondary);
}
.step-link {
  display: inline-block;
  margin-top: 8px;
  font-size: 13px;
  color: var(--el-color-primary);
  text-decoration: none;
}
.step-link:hover {
  text-decoration: underline;
  line-height: 1.4;
}

.guide-restore-bar {
  padding: 12px 0;
}

.guide-restore-bar .el-button {
  font-size: 14px;
}

/* 订单分布 */
.order-map-chart {
  min-height: 320px;
  width: 100%;
  border-radius: var(--card-radius);
}

.order-map-fallback {
  min-height: 320px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--main-bg);
  border-radius: var(--card-radius);
  color: var(--text-secondary);
  font-size: 14px;
  padding: 20px;
}

.date-range {
  margin-right: 8px;
}

@media (max-width: 768px) {
  .guide-steps {
    grid-template-columns: 1fr;
  }
}
</style>
