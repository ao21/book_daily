Chartkick.options = {
  height: "250px",
  width: "500px",
  donut: true,
  colors: [ "#4756ca",
            "#bdbdbd"
          ],
  message: { empty: "データがありません" },
  suffix: "%",
  legend: false, # 凡例非表示
  library: { # ここから highcharts の設定
    title: {
      align: 'center',
      verticalAlign: 'middle',
      style: {
        color: "#163172",
        fontWeight: "bold",
        fontSize: "30px"
      }
    },
    plotOptions: {
      series: {
        enableMouseTracking: false # hover や tooltip を無効化
      },
      pie: {
        dataLabels: {
          enabled: false,
        },
        size: '110%',
        innerSize: '60%',
        borderWidth: 0,
      }
    }
  }
}