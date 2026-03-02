# AI-Powered Worker Productivity Dashboard

A full-stack web application that ingests AI-generated events from CCTV computer vision systems and displays productivity metrics for a manufacturing factory.

## Quick Start with Desktop Shortcut

### Option 1: One-Click Launch (Recommended)
1. Run the PowerShell script to create Desktop shortcut:
```
powershell -ExecutionPolicy Bypass -File create-shortcut.ps1
```
2. Double-click the **"Docker Desktop"** shortcut on your Desktop
3. The dashboard will open automatically in your browser!

### Option 2: Manual Launch
1. Double-click `start-dashboard.bat` in the CCTV folder
2. Wait for Docker containers to build and start
3. The dashboard will open automatically in your browser

**Note:** Data is automatically seeded on first startup. The dashboard works completely offline from VS Code - containers run independently!

## Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  AI CCTV       │     │  Express.js     │     │  SQL.js        │
│  Cameras       │────▶│  Backend        │────▶│  Database       │
│  (Edge)        │     │  (Port 8000)    │     │                 │
└─────────────────┘     └────────┬────────┘     └─────────────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │  React Dashboard │
                        │  (Port 3000)     │
                        └──────────────────┘
```

### Data Flow
1. **Edge (CCTV Cameras)**: AI-powered computer vision system processes video feeds and generates structured events
2. **Backend API**: Receives events via REST API, stores in database, computes metrics
3. **Dashboard**: Fetches and displays computed metrics in real-time

## Quick Start

### Prerequisites
- Docker & Docker Compose

### Running Locally

#### Option 1: Docker Compose

```
bash
docker-compose up --build
```

## API Endpoints

### Events
- `POST /api/events` - Ingest new AI event
- `GET /api/events` - List events (with filters)
- `POST /api/events/seed` - Generate dummy data

### Workers
- `GET /api/workers` - List all workers
- `GET /api/workers/:worker_id/metrics` - Get worker metrics

### Workstations
- `GET /api/workstations` - List all workstations
- `GET /api/workstations/:station_id/metrics` - Get workstation metrics

### Factory
- `GET /api/metrics/factory` - Get factory-level metrics
- `GET /api/dashboard` - Get all dashboard data

## Sample Event Format

```
json
{
  "timestamp": "2026-01-15T10:15:00Z",
  "worker_id": "W1",
  "workstation_id": "S3",
  "event_type": "working",
  "confidence": 0.93,
  "count": 1
}
```

### Event Types
- `working` - Worker is actively working
- `idle` - Worker is at station but idle
- `absent` - Worker is not at station
- `product_count` - Units produced at workstation

## Database Schema

### Workers Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| worker_id | TEXT | Unique identifier (W1-W6) |
| name | TEXT | Worker name |

### Workstations Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| station_id | TEXT | Unique identifier (S1-S6) |
| name | TEXT | Station name |

### Events Table
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| timestamp | TEXT | Event timestamp (ISO 8601) |
| worker_id | TEXT | Foreign key to workers |
| workstation_id | TEXT | Foreign key to workstations |
| event_type | TEXT | working/idle/absent/product_count |
| confidence | REAL | AI confidence score (0-1) |
| count | INTEGER | Units produced (for product_count) |

## Metrics Definitions

### Worker-Level Metrics
- **Total Active Time**: Sum of durations where event_type = 'working'
- **Total Idle Time**: Sum of durations where event_type = 'idle'
- **Utilization %**: (Active Time / Total Time) × 100
- **Total Units Produced**: Sum of count for 'product_count' events
- **Units Per Hour**: Total Units / (Active Time in hours)

### Workstation-Level Metrics
- **Occupancy Time**: Sum of durations where worker is present
- **Utilization %**: (Occupancy Time / Total Time) × 100
- **Total Units Produced**: Sum of count for 'product_count' events
- **Throughput Rate**: Units Produced / Occupancy Time (hours)

### Factory-Level Metrics
- **Total Productive Time**: Sum of all 'working' event durations
- **Total Production Count**: Sum of all 'product_count' event counts
- **Average Production Rate**: Total Units / Total Active Time
- **Average Utilization**: Mean of all worker utilizations

## Assumptions & Tradeoffs

1. **Time Calculation**: Duration between consecutive events is calculated and capped at 60 minutes to prevent outliers
2. **Last Event Handling**: Last event in sequence assumed to have 30-minute duration
3. **Product Count Association**: Production events are linked to the preceding time-based activity event
4. **Absent Detection**: Workers without events during a time period are considered absent

## Theoretical Questions

### 1. How do you handle intermittent connectivity?

**Edge Layer Solutions:**
- Implement local buffering on CCTV cameras with persistent storage (SD card/local SSD)
- Use message queue systems (RabbitMQ, Apache Kafka) at the edge for reliable delivery
- Implement exponential backoff with jitter for retry mechanisms
- Store events with batch IDs to ensure ordering

**Network Layer Solutions:**
- Use MQTT or AMQP protocols optimized for unreliable networks
- Implement store-and-forward architecture
- Add heartbeat/health check endpoints

**Backend Solutions:**
- Implement event ingestion buffer with async processing
- Use database transactions with idempotency keys
- Queue-based processing with dead-letter queues for failed events

### 2. How do you handle duplicate events?

**Prevention:**
- Generate unique event IDs at the source (CCTV cameras)
- Use composite unique constraint on (timestamp, worker_id, workstation_id, event_type)
- Implement idempotency keys in API layer

**Detection:**
- Hash-based deduplication using SHA-256 of event content
- Time-window based deduplication (within 1-second window)
- Bloom filters for initial fast check, database lookup for confirmation

**Resolution:**
- Return 409 Conflict status for exact duplicates
- Upsert behavior for near-duplicates (same worker/station/time)
- Deduplication log for auditing

### 3. How do you handle out-of-order timestamps?

**At Ingestion:**
- Buffer events in memory with configurable window (e.g., 5 minutes)
- Use event timestamp (not received timestamp) for ordering
- Implement timestamp validation (reject future dates > current time)

**At Processing:**
- Sort events by timestamp before metric computation
- Use event sequence numbers in addition to timestamps
- Implement sliding window aggregations that handle late-arriving events

**At Storage:**
- Database indexes on timestamp columns
- Time-series database extensions for efficient temporal queries
- Compaction process for out-of-order writes

### 4. How would you add model versioning?

**Version Tracking:**
- Include model_version in event metadata
- Semantic versioning (v1.0, v1.1, v2.0)
- Model registry in database or MLflow/Kubeflow

**Versioning Strategy:**
```
json
Events Schema:
{
  "timestamp": "...",
  "model_version": "v2.1.0",
  "model_metadata": {
    "training_date": "2026-01-01",
    "accuracy": 0.94,
    "framework": "tensorflow"
  }
}
```

**Rollback Support:**
- Maintain historical model configurations
- A/B testing with percentage-based routing
- Feature flags per model version
- Blue-green deployment for model updates

### 5. How would you detect model drift?

**Data Drift Detection:**
- Population Stability Index (PSI) on input features
- Kolmogorov-Smirnov test for feature distribution changes
- Feature importance drift over time

**Performance Drift:**
- Monitor prediction confidence distributions
- Track false positive/negative rates over time
- Concept drift detection using ADWIN algorithm

**Alerting:**
```
Drift Detection Rules:
- PSI > 0.25: Significant distribution shift
- Confidence drop > 10%: Model may be degrading
- Error rate increase > 5%: Retraining recommended
```

**Dashboard Metrics:**
- Real-time confidence score distribution
- Weekly/monthly performance trends
- Anomaly detection alerts

### 6. How would you trigger retraining?

**Automated Triggers:**
- Scheduled retraining (weekly/monthly)
- Performance threshold-based (accuracy < 90%)
- Data drift threshold-based (PSI > 0.25)
- Manual trigger via API

**Retraining Pipeline:**
```
1. Data Collection → 2. Preprocessing → 3. Training → 4. Validation → 5. Deployment
                      ↑                                              │
                      └───────── Rollback if metrics worse ─────────┘
```

**Canary Deployment:**
- Deploy new model to 5% of traffic
- Monitor error rates and confidence scores
- Gradual rollout if metrics improve
- Automatic rollback if degradation detected

### 7. How does this scale from 5 cameras → 100+ cameras → multi-site?

**5 Cameras (Current)**
- Single backend server
- SQLite database
- Simple load balancing not required

**100+ Cameras**
```
Architecture Changes:
├── Load Balancer (nginx/HAProxy)
├── Multiple Backend Instances (auto-scaling)
├── Redis Cache (session, metrics cache)
├── PostgreSQL (instead of SQLite)
└── Message Queue (RabbitMQ/Kafka)
```

**Scaling Strategy:**
1. **Horizontal Scaling**: Multiple backend instances behind load balancer
2. **Database Sharding**: Partition by worker_id or time range
3. **Caching**: Redis for frequently accessed metrics
4. **Event Batching**: Batch events from cameras before processing
5. **Async Processing**: Use message queues for metric computation

**Multi-Site Deployment**
```
Global Load Balancer
    ├── Site 1 (Region US-East)
    │   ├── Local CCTV Cameras
    │   ├── Local Backend Cluster
    │   └── Local Database (primary)
    ├── Site 2 (Region EU-West)
    │   ├── Local CCTV Cameras
    │   ├── Local Backend Cluster
    │   └── Local Database (replica)
    └── Central Analytics
        └── Aggregated Metrics Dashboard
```

**Cross-Site Considerations:**
- Data replication with conflict resolution
- Consistent hashing for event routing
- Timezone handling for global metrics
- Regional compliance (GDPR, data residency)
- Network latency optimization with CDN

## Tech Stack

- **Backend**: Express.js + SQL.js (SQLite in-browser)
- **Frontend**: React + Vite + TypeScript
- **Database**: SQLite (can be swapped for PostgreSQL)
- **Containerization**: Docker + Docker Compose

## License

MIT License
