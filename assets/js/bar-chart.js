import Chart from "chart.js";
import { CHART_COLORS } from "./chart-colors.js";

class BarChart {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Total votes",
            data: values,
            backgroundColor: Object.values(CHART_COLORS),
          },
        ],
      },
      options: {
        responsive: true,
        legend: {
          display: false
        },
        scales: {
          xAxes: [
            {
              ticks: {
                fontStyle: "bold",
                fontSize: 14,
              },
            },
          ],
          yAxes: [
            {
              ticks: {
                stepSize: 1,
                suggestedMin: 0,
                suggestedMax: 3,
                fontStyle: "bold",
                fontSize: 14,
              },
            },
          ],
        }
      },
    });
  }
}

export default BarChart;
