import BarChart from "./bar-chart"

let Hooks = {};

Hooks.BarChart = {
  mounted() {
    const { labels, values } = JSON.parse(this.el.dataset.chartData)
    this.chart = new BarChart(this.el, labels, values)

    this.handleEvent("update-votes", ({ labels, values }) => {
      this.chart.updateChart(labels, values)
    })
  }
}

export default Hooks;
