# Statistics API Integration Guide

## Overview
This document describes the implementation of the comprehensive statistics endpoint in the Flutter wellness app.

## Endpoint Details

### GET /api/statistics/

Retrieve comprehensive user statistics with various filtering options.

**Base URL:** `https://app.sangam1313.com.np`

**Full Endpoint:** `https://app.sangam1313.com.np/api/statistics/`

## Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `period` | string | Time period filter | `7days`, `30days`, `90days`, `all`, `custom` |
| `start_date` | string (ISO 8601) | Start date for custom period | `2026-01-21T00:00:00.000Z` |
| `end_date` | string (ISO 8601) | End date for custom period | `2026-01-28T23:59:59.999Z` |

## Response Structure

```json
{
  "period": "7days",
  "start_date": "2026-01-21T00:00:00.000Z",
  "end_date": "2026-01-28T23:59:59.999Z",
  "overview": {
    "total_activities": 15,
    "total_duration": 450,
    "average_duration": 30.0,
    "total_goals_set": 10,
    "goals_achieved": 7,
    "goal_completion_rate": 70.0
  },
  "activity_breakdown": {
    "Yoga": 5,
    "Running": 4,
    "Meditation": 6
  },
  "daily_activity_count": [
    {
      "date": "2026-01-21",
      "count": 3
    },
    {
      "date": "2026-01-22",
      "count": 2
    }
  ],
  "daily_duration": [
    {
      "date": "2026-01-21",
      "duration": 60
    },
    {
      "date": "2026-01-22",
      "duration": 45
    }
  ],
  "motivation_trends": {
    "average_motivation": 7.5,
    "trend": "upward",
    "motivation_distribution": {
      "High": 10,
      "Medium": 3,
      "Low": 2
    }
  },
  "engagement": {
    "active_days": 5,
    "total_days": 7,
    "engagement_rate": 71.4,
    "current_streak": 3,
    "longest_streak": 5
  },
  "ratings": {
    "average_rating": 4.2,
    "total_ratings": 15,
    "rating_distribution": {
      "5": 8,
      "4": 5,
      "3": 2,
      "2": 0,
      "1": 0
    }
  },
  "goal_progress": {
    "total_goals": 10,
    "completed_goals": 7,
    "in_progress_goals": 3,
    "completion_percentage": 70.0
  },
  "recent_activities": [
    {
      "id": 123,
      "name": "Morning Yoga",
      "category": "Yoga",
      "duration": 30,
      "completed_at": "2026-01-28T08:00:00.000Z",
      "rating": 5.0,
      "motivation_level": "High"
    }
  ]
}
```

## Usage in Flutter App

### 1. Model Classes

The following model classes have been created:

- `ComprehensiveStatsModel` - Main statistics model
- `StatsOverview` - Overview statistics
- `DailyActivityCount` - Daily activity count data
- `DailyDuration` - Daily duration data
- `MotivationTrends` - Motivation trends and distribution
- `EngagementStats` - User engagement metrics
- `RatingStats` - Activity ratings statistics
- `GoalProgress` - Goal progress tracking
- `RecentActivity` - Recent activity details

Location: `lib/features/stats/models/comprehensive_stats_model.dart`

### 2. Provider Method

The `StatsProvider` includes the `fetchComprehensiveStats` method:

```dart
await provider.fetchComprehensiveStats(
  period: '7days',
  startDate: DateTime(2026, 1, 21),
  endDate: DateTime(2026, 1, 28),
);
```

**Parameters:**
- `period` (optional): Time period string (default: '7days')
- `startDate` (optional): Custom start date
- `endDate` (optional): Custom end date

**Access the data:**
```dart
final stats = provider.comprehensiveStats;
```

### 3. UI Screen

A comprehensive statistics screen has been created at:
`lib/features/stats/screens/comprehensive_stats_screen.dart`

**Features:**
- Period selector (7 days, 30 days, 90 days, all time, custom)
- Overview cards showing key metrics
- Engagement statistics with streaks
- Activity breakdown charts
- Daily activity count line chart
- Daily duration bar chart
- Motivation trends
- Rating statistics with distribution
- Goal progress tracking
- Recent activities list

### 4. Navigation

The comprehensive stats screen is integrated into the app router at `/stats`

```dart
context.go('/stats');
```

## Example API Calls

### Get 7-day statistics
```
GET /api/statistics/?period=7days
```

### Get 30-day statistics
```
GET /api/statistics/?period=30days
```

### Get custom date range
```
GET /api/statistics/?period=custom&start_date=2026-01-01T00:00:00.000Z&end_date=2026-01-28T23:59:59.999Z
```

### Get all-time statistics
```
GET /api/statistics/?period=all
```

## Implementation Details

### API Service Call

```dart
final queryParams = <String, dynamic>{
  'period': period,
};

if (period == 'custom' && startDate != null && endDate != null) {
  queryParams['start_date'] = startDate.toIso8601String();
  queryParams['end_date'] = endDate.toIso8601String();
}

final response = await _apiService.get(
  '/api/statistics/',
  queryParams: queryParams,
);
```

### Error Handling

The provider includes comprehensive error handling:
- Loading state management
- Error state with user-friendly messages
- Automatic retry functionality in UI
- Null safety for all data fields

## Charts and Visualizations

The screen uses `fl_chart` package to display:

1. **Line Chart** - Daily activity count over time
2. **Bar Chart** - Daily duration in minutes
3. **Progress Indicators** - Activity breakdown percentages
4. **Linear Progress** - Goal completion rate
5. **Rating Distribution** - Star ratings breakdown

## Constants

API endpoint constant added to `lib/core/constants/api_constants.dart`:

```dart
static const String comprehensiveStats = '/api/statistics/';
```

## Testing

To test the implementation:

1. Ensure you're authenticated
2. Navigate to the Stats screen
3. Select different time periods
4. Try custom date range selection
5. Pull to refresh to reload data
6. Check error handling by disconnecting from network

## Future Enhancements

Potential improvements:
- Export statistics to PDF/CSV
- Compare periods side-by-side
- Share statistics on social media
- Offline caching of statistics
- Push notifications for achievements
- Predictive analytics and trends
