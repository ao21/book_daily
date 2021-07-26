Chartkick.options = {
  height: "250px",
  width: "500px",
  donut: true, # ドーナツグラフ
  colors: [ "#4756ca",
            "#bdbdbd"
          ],
  message: { empty: "データがありません" },
  suffix: "%",
  legend: false, # 凡例非表示
  library: {
    title: { # タイトル表示(ここでは、グラフの真ん中に配置して,viewでデータを渡しています。*後述)
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
        enableMouseTracking: false
      },
      pie: {
        dataLabels: {
          enabled: false,
        },
        size: '110%',
        innerSize: '60%', # ドーナツグラフの中の円の大きさ
        borderWidth: 0,
      }
    }
  }
}