import Dispatch

/// Потокобезопасное значение
final class SynchronizedValue<ValueType : Any> {
    
    // MARK: - Приватные свойства
    
    /// Очередь для осуществления доступа
    private let accessQueue: DispatchQueue
    
    /// Значение
    private var backingValue: ValueType
    
    
    // MARK: - Инициализация
    
    init(_ value: ValueType, queueLabel label: String = String(describing: type(of: SynchronizedValue.self))) {
        self.accessQueue = DispatchQueue(label: label, attributes: .concurrent)
        self.backingValue = value
    }
    
}


// MARK: - Публичные свойства

extension SynchronizedValue {
    
    /// Безопасное значение
    var value: ValueType {
        get {
            return get()
        }
        set {
            asyncSet { $0 = newValue }
        }
    }
    
    /// Небезопасное значение
    var unsafeValue: ValueType {
        get {
            return self.backingValue
        }
        set {
            self.backingValue = newValue
        }
    }
    
}


// MARK: - Публичные методы

extension SynchronizedValue {
    
    // MARK: Безопасный доступ
    
    /// Безопасно получить значение
    func get() -> ValueType {
        var value: ValueType!
        self.accessQueue.sync {
            value = self.backingValue
        }
        
        return value
    }
    
    /// Синхронно безопасно присвоить значение
    func syncSet(_ closure: @escaping (inout ValueType) -> ()) {
        self.accessQueue.sync(flags: .barrier) {
            closure(&self.backingValue)
        }
    }
    
    /// Асинхронно безопасно присвоить значение
    func asyncSet(_ closure: @escaping (inout ValueType) -> ()) {
        self.accessQueue.async(flags: .barrier) {
            closure(&self.backingValue)
        }
    }
    
    
    // MARK: Небезопасный доступ
    
    /// Небезопасно получить значение
    func getUnsafeValue() -> ValueType {
        return self.backingValue
    }
    
    /// Небезопасно присвоить значение
    func setUnsafeValue(_ closure: (inout ValueType) -> ()) {
        closure(&self.backingValue)
    }
    
}
