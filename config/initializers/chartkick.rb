Chartkick.options = {
  height: "250px",
  width: "500px",
  donut: true,
  colors: [ "#219ebc",
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
        color: "#219ebc",
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
        size: '100%',
        innerSize: '80%',
        borderWidth: 0,
      }
    }
  }
}