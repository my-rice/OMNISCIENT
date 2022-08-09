import UIKit
import CoreData
import Charts

class AnalogChartController: UIViewController, ChartViewDelegate   {
    var lineChart = LineChartView()
    var sensor: Sensor?
    var timer: Timer?
    
    func initialize(sensor: Sensor) {
        self.sensor = sensor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = sensor!.name!
        lineChart.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("willAppear")
        StateModel.shared.fetchState()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.fetchState), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("willDisappear")
        timer?.invalidate()
        timer=nil
    }
    
    @objc func fetchState(){
        //print("test")
        StateModel.shared.fetchState()
        let analog_sensors_data = StateModel.shared.current_state?.analog_sensor_data
        var sensor_data = (analog_sensors_data?[sensor!.remoteID!]?.data)!
        sensor_data.reverse()
        let set = LineChartDataSet(entries: sensor_data.map{d in
            let time = Double(d.time.timeIntervalSinceNow)
            print((d.time,time,d.value))
            return ChartDataEntry(x: time, y: d.value)
        })
        set.drawCirclesEnabled = false //Non voglio i cerchi sul grafico
        set.mode = .horizontalBezier //Smussa un po' le curve
        set.lineWidth = 4 //Spessore della linea
        set.setColor(.black) //Colore della linea
//      Se voglio colorare l'integrale abilito queste istruzioni
//        set.fill = Fill(color: .white)
//        set.fillAlpha = 0.8
//        set.drawFilledEnabled = true
        
//      Inserisco i dati nel grafico
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        lineChart.data = data
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-20, height: self.view.frame.width)
        lineChart.center = view.center
        view.addSubview(lineChart)
        
//      Configuro il chart
        lineChart.backgroundColor = .systemGray6
        lineChart.rightAxis.enabled = false
        lineChart.doubleTapToZoomEnabled = false //Disattivo la possibilità di zoomare il grafico
        
        let yAxis = lineChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .black // Setto il colore dei numeri sull'asse y
//        yAxis.labelPosition = .insideChart
        yAxis.axisLineColor = .black //Setto il colore dell'asse a sinistra
        yAxis.drawGridLinesEnabled = false
        
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .black // Setto il colore dei numeri sull'asse y
//        xAxis.labelPosition = .insideChart
        xAxis.axisLineColor = .black //Setto il colore dell'asse a sinistra
        xAxis.drawGridLinesEnabled = false
//        lineChart.animate(xAxisDuration: 0.5) //Setto un'animazione del grafico. Impiega 0.5 secondi a popolare il grafico
        
//        set.colors = ChartColorTemplates.material() // Setto un template per le linee. Non fa al nostro caso
        //let set: LineChartDataSet = AnalogSensorDataSet(sensor:self.sensor!,c:lineChart)
        fetchState()
    }
    
}