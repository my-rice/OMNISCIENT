import UIKit
import CoreData
import Charts

class DigitalChartController: UIViewController, ChartViewDelegate  {
    var barChart = BarChartView()
    var sensor: Sensor?
    var timer: Timer?
    
    func initialize(sensor: Sensor) {
        self.sensor = sensor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = sensor!.name!
        barChart.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("willAppear")
        StateModel.shared.fetchState()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.fetchState), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("willDisappear")
        timer?.invalidate()
        timer=nil
    }
    
    @objc func fetchState(){
        //print("test")
        StateModel.shared.fetchState()
        let digital_sensors_data = StateModel.shared.current_state?.digital_sensor_data
        let sensor_data: [FetchedDigitalDataPoint] = (digital_sensors_data?[sensor!.remoteID!]?.data) ?? []
        let movements: [Int] = sensor_data.map {d in
            let time = Double(d.time.timeIntervalSinceNow)
            return Int(time)
        }
        print(movements)
        var chart_data: [BarChartDataEntry] = (Int(-60)...Int(0)).map{i in
            if movements.contains(i){
                return BarChartDataEntry(x: Double(i), y: 1.0)
            }
            return BarChartDataEntry(x: Double(i), y: 0.0)
        }
        print(chart_data)
        let set = BarChartDataSet(entries: chart_data)
        set.setColor(.black) //Colore della linea
//      Se voglio colorare l'integrale abilito queste istruzioni
//        set.fill = Fill(color: .white)
//        set.fillAlpha = 0.8
//        set.drawFilledEnabled = true
        
//      Inserisco i dati nel grafico
        let data = BarChartData(dataSet: set)
        data.setDrawValues(false)
        barChart.data = data
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-20, height: self.view.frame.width)
        barChart.center = view.center
        view.addSubview(barChart)
        
//      Configuro il chart
        barChart.backgroundColor = .systemGray6
        barChart.rightAxis.enabled = false
        barChart.doubleTapToZoomEnabled = false //Disattivo la possibilità di zoomare il grafico
        
        
        
        let yAxis = barChart.leftAxis
        yAxis.spaceBottom = 0 //Attacca all'asse x gli istogrammi
        yAxis.drawLabelsEnabled = false // Non mostra le label sull'asse y
        yAxis.drawGridLinesEnabled = false
//        yAxis.axisMinLabels = 0
//        yAxis.labelFont = .boldSystemFont(ofSize: 12)
//        yAxis.setLabelCount(2, force: true)
//        yAxis.labelTextColor = .black // Setto il colore dei numeri sull'asse y
//        yAxis.axisLineColor = .black //Setto il colore dell'asse a sinistra

        let xAxis = barChart.xAxis
        
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
//        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .black // Setto il colore dei numeri sull'asse y
        xAxis.axisLineColor = .black //Setto il colore dell'asse a sinistra
        xAxis.drawGridLinesEnabled = false
//        lineChart.animate(xAxisDuration: 0.5) //Setto un'animazione del grafico. Impiega 0.5 secondi a popolare il grafico
        
        
        
        
        /*let set: BarChartDataSet = setData()
//        set.colors = ChartColorTemplates.material() // Setto un template per le linee. Non fa al nostro caso
        
//      Inserisco i dati nel grafico
        let data = BarChartData(dataSet: set)
        data.setDrawValues(false)
        barChart.data = data*/
    }
    
    
    
/*    func setData() -> BarChartDataSet {
        
        //      Creo dei dati per testare
        var entries = [BarChartDataEntry]()
        
        
        //Nota: La distanza fra due barre deve essere almeno 2 unità
        for x in stride(from: -120, to: 0, by: 2){
            entries.append(BarChartDataEntry(x: Double(x), y: 0))
            entries.append(BarChartDataEntry(x: Double(x)+Double(0.5), y: 1))
        }
        
        
        let set = BarChartDataSet(entries: entries)
        return set
    }
*/
}
