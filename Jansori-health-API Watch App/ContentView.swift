import SwiftUI
import HealthKit

struct ContentView: View {
    // HealthKit 저장소 생성
    let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            Text("잔소리 건강 앱")
                .font(.headline)
            
            Button("심박수 가져오기") {
                requestHealthAuthorization()
            }
        }
        .padding()
    }
    
    func requestHealthAuthorization() {
        // 심박수 데이터 타입
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        // 읽기 권한 요청
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                print("HealthKit 권한 허용됨")
                fetchHeartRateData()
            } else if let error = error {
                print("권한 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchHeartRateData() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        // 최근 심박수 데이터 가져오기
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            if let error = error {
                print("심박수 데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            if let sample = results?.first as? HKQuantitySample {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                print("최근 심박수: \(heartRate) bpm")
            }
        }
        
        healthStore.execute(query)
    }
}
