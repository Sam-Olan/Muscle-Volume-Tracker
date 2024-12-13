import SwiftUI

struct CustomCalendarView: View {
    // MARK: - Properties
    @Binding var selectedDate: Date
    let maxDate: Date
    
    // MARK: - Private Properties
    private var months: [Date] {
        let currentMonth = Calendar.shared.date(from: Calendar.shared.dateComponents([.year, .month], from: maxDate))!
        return stride(from: 11, through: 0, by: -1).compactMap { monthsAgo in
            Calendar.shared.date(byAdding: .month, value: -monthsAgo, to: currentMonth)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: CalendarConstants.monthSpacing) {
                    ForEach(months, id: \.self) { month in
                        monthView(for: month)
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                scrollToSelectedMonth(proxy: proxy)
            }
        }
    }
    
    // MARK: - Private Views
    private var dayHeaderView: some View {
        HStack {
            ForEach(CalendarConstants.weekDays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 4)
        .padding(.horizontal)
    }
    
    private func monthView(for month: Date) -> some View {
        VStack {
            Text(DateFormatters.monthYear.string(from: month))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            dayHeaderView
            
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    dateGrid(for: month)
                    weekHighlightBar(for: month, in: geometry)
                }
            }
            .frame(height: CalendarConstants.cellHeight * 6)
            .padding(.horizontal)
            
            if month != months.last {
                Divider()
                    .padding(.top, 8)
            }
        }
        .id(month)
    }
    
    // MARK: - Helper Methods
    private func daysInMonth(for date: Date) -> [Date?] {
        let components = Calendar.shared.dateComponents([.year, .month], from: date)
        guard let monthStart = Calendar.shared.date(from: components),
              let range = Calendar.shared.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        
        let firstWeekday = Calendar.shared.component(.weekday, from: monthStart) - 1
        let prefixDays = Array(repeating: nil as Date?, count: firstWeekday)
        
        let monthDays = range.compactMap { day -> Date? in
            Calendar.shared.date(byAdding: .day, value: day - 1, to: monthStart)
        }
        
        let totalCount = prefixDays.count + monthDays.count
        let suffixCount = (7 - (totalCount % 7)) % 7
        let suffixDays = Array(repeating: nil as Date?, count: suffixCount)
        
        return prefixDays + monthDays + suffixDays
    }
    
    private func isDateInCurrentWeek(_ date: Date) -> Bool {
        let today = Date()
        let currentWeekStart = Calendar.shared.date(from: Calendar.shared.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let dateWeekStart = Calendar.shared.date(from: Calendar.shared.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return Calendar.shared.isDate(currentWeekStart, equalTo: dateWeekStart, toGranularity: .day)
    }
    
    private func scrollToSelectedMonth(proxy: ScrollViewProxy) {
        let selectedMonth = Calendar.shared.date(
            from: Calendar.shared.dateComponents([.year, .month], from: selectedDate)
        )!
        withAnimation {
            proxy.scrollTo(selectedMonth, anchor: .center)
        }
    }
    
    private func dateGrid(for month: Date) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInMonth(for: month), id: \.self) { date in
                if let date = date {
                    dateCellView(for: date)
                } else {
                    Text("")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
    }
    
    private func dateCellView(for date: Date) -> some View {
        let isInCurrentWeek = isDateInCurrentWeek(date)
        let isSelectable = date <= maxDate
        let isFutureDate = date > Date()
        
        return Text(String(Calendar.shared.component(.day, from: date)))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(
                isFutureDate ? .gray :
                    (isInCurrentWeek ? .blue : (isSelectable ? .primary : .gray))
            )
            .onTapGesture {
                if isSelectable {
                    selectedDate = date
                }
            }
    }
    
    private func weekHighlightBar(for month: Date, in geometry: GeometryProxy) -> some View {
        let calendar = Calendar.shared
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        let weekDates = (0...6).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        
        let datesInMonth = weekDates.filter { calendar.isDate($0, equalTo: month, toGranularity: .month) }
        
        return Group {
            if !datesInMonth.isEmpty,
               let firstDate = datesInMonth.first,
               let lastDate = datesInMonth.last {
                
                let cellWidth = geometry.size.width / 7
                let cellHeight = CalendarConstants.cellHeight
                
                // Get the first day's position in the calendar grid
                let firstDayOfMonthWeekday = calendar.component(.weekday, from: monthStart) - 1
                let dayOfMonth = calendar.component(.day, from: firstDate)
                
                // Calculate the grid position (0-based)
                let gridPosition = dayOfMonth + firstDayOfMonthWeekday - 1
                
                // Calculate the row (0-based)
                let row = gridPosition / 7
                
                // Calculate vertical position with reduced movement
                let reducedCellHeight = cellHeight * 0.93
                let verticalOffset: CGFloat = -5
                let yPosition = (CGFloat(row) * reducedCellHeight) + (cellHeight / 2) + verticalOffset
                
                // Calculate horizontal position using weekday
                let startWeekday = calendar.component(.weekday, from: firstDate) - 1
                let endWeekday = calendar.component(.weekday, from: lastDate) - 1
                let startX = CGFloat(startWeekday) * cellWidth
                let width = CGFloat(endWeekday - startWeekday + 1) * cellWidth
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: width, height: cellHeight - 8)
                    .position(x: startX + (width / 2), y: yPosition)
            } else {
                Color.clear
            }
        }
    }
} 