# AI-Powered Worker Productivity Dashboard - Specification

## Project Overview
- **Project Name**: Worker Productivity Dashboard
- **Type**: Full-stack Web Application
- **Core Functionality**: Ingest AI-generated CCTV events, compute productivity metrics, display in dashboard
- **Target Users**: Factory managers, operations supervisors

## Technology Stack
- **Backend**: FastAPI (Python) - modern, fast, built-in validation
- **Database**: SQLite with SQLAlchemy ORM
- **Frontend**: React + Vite + TypeScript
- **Containerization**: Docker + Docker Compose

## Architecture
```
[AI CCTV Cameras] → [FastAPI Backend] → [SQLite Database]
                                         ↓
                              [React Dashboard]
```

## Database Schema

### Workers Table
| Column | Type | Description |
|--------|------|-------------|
| id | Integer (PK) | Auto-increment ID |
| worker_id | String | Unique worker identifier (W1-W6) |
| name | String | Worker name |

### Workstations Table
| Column | Type | Description |
|--------|------|-------------|
| id | Integer (PK) | Auto-increment ID |
| station_id | String | Unique station identifier (S1-S6) |
| name | String | Station name/type |

### Events Table
| Column | Type | Description |
|--------|------|-------------|
| id | Integer (PK) | Auto-increment ID |
| timestamp | DateTime | Event timestamp |
| worker_id | String | Foreign key to workers |
| workstation_id | String | Foreign key to workstations |
| event_type | String | working/idle/absent/product_count |
| confidence | Float | AI confidence score (0-1) |
| count | Integer | Units produced (for product_count) |

## API Endpoints

### Events
- `POST /api/events` - Ingest new event
- `GET /api/events` - List events (with filters)
- `POST /api/events/seed` - Generate dummy data

### Workers
- `GET /api/workers` - List all workers
- `GET /api/workers/{worker_id}/metrics` - Get worker metrics

### Workstations
- `GET /api/workstations` - List all workstations
- `GET /api/workstations/{station_id}/metrics` - Get workstation metrics

### Factory
- `GET /api/metrics/factory` - Get factory-level metrics

## Metrics Calculations

### Worker-Level Metrics
- **Total Active Time**: Sum of duration where event_type = 'working'
- **Total Idle Time**: Sum of duration where event_type = 'idle'
- **Utilization %**: (Active Time / Total Time) * 100
- **Total Units Produced**: Sum of count for 'product_count' events
- **Units Per Hour**: Total Units / (Total Time in hours)

### Workstation-Level Metrics
- **Occupancy Time**: Sum of duration where worker is present
- **Utilization %**: (Occupancy Time / Total Time) * 100
- **Total Units Produced**: Sum of count for 'product_count' events
- **Throughput Rate**: Units Produced / Occupancy Time

### Factory-Level Metrics
- **Total Productive Time**: Sum of all 'working' events duration
- **Total Production Count**: Sum of all 'product_count' events count
- **Average Production Rate**: Total Units / Total Active Time
- **Average Utilization**: Mean of all worker utilizations

## Assumptions
1. Events with same worker_id between timestamps represent continuous activity
2. If no event recorded, worker is assumed 'absent'
3. Default event duration is 1 hour if not specified
4. Product count events are associated with preceding working event

## Sample Data
- 6 Workers: W1-W6 (John, Sarah, Mike, Emily, David, Lisa)
- 6 Workstations: S1-S6 (Assembly, Welding, Painting, Quality, Packaging, Shipping)
- 100+ pre-seeded events for demonstration

## Edge Cases Handled
- Duplicate events: Check for existing (timestamp, worker_id, workstation_id) combination
- Out-of-order timestamps: Sort by timestamp before calculations
- Missing worker/workstation: Return 404 error
- Empty database: Provide seed endpoint

## Theoretical Questions (to be answered in README)
1. Intermittent connectivity handling
2. Duplicate event handling
3. Out-of-order timestamp processing
4. Model versioning approach
5. Model drift detection
6. Retraining triggers
7. Scaling from 5 to 100+ cameras to multi-site
