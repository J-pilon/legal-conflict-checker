# Legal Conflict Checker

## Overview

**This is a prototype** for an automated conflict checking system designed to assist legal firms in identifying potential conflicts of interest during client intake. The system analyzes prospective legal matters against historical matters, attorneys, and related parties to surface possible conflicts for human review.

## Getting Started

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd legal_conflict_checker
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

### Running the Server

Start the Rails server:
```bash
rails s
```

The application will be available at `http://localhost:3000`.

**Running with Feature Flag Disabled:**

To disable the conflict collector service (for testing or debugging):
```bash
CONFLICT_COLLECTOR_ENABLED=false rails s
```

### Testing

Test the new intake endpoint with a sample matter:

```bash
curl -X POST http://localhost:3000/new_intake/create \
  -H "Content-Type: application/json" \
  -d '{
    "matter_number": "2024-1076",
    "title": "Martinez Restaurant Group Employment Dispute",
    "client_name": "Commercial Bank",
    "client_type": "Corporation",
    "practice_area": "Employment Law",
    "matter_type": "Discrimination",
    "status": "Active",
    "opened_date": "2024-05-15",
    "closed_date": null,
    "adverse_parties": ["Former Employee", "EEOC"],
    "related_parties": ["Jennifer Martinez (Legal Counsel)", "HR Department Staff"],
    "assigned_attorney": "Sarah Williams",
    "description": "Employment contract negotiation for senior physician position",
    "conflict_check_completed_date": null
  }'
```

View conflict check results on the dashboard at `http://localhost:3000/dashboard`.

## What This Project Does

The Legal Conflict Checker automatically scans existing matters and attorney data when a new matter is submitted for intake. It uses multiple detection algorithms to identify potential conflicts based on:

- **Concurrent conflicts**: When related parties from prior matters match the prospective client name
- **Lawyer-client conflicts**: When the assigned attorney has business interests that conflict with a former client
- **Successive conflicts**: When a prospective matter involves the same client or related matter as a previous engagement

The system presents a ranked list of "Possible Conflicts" (not definitive conflicts) to a designated reviewer, who then makes the final determination. All conflict checks and review decisions are logged with timestamps for audit purposes.

## Key Components

### Models
- **LegalMatter**: Represents a legal matter with attributes such as client name, practice area, matter type, adverse parties, related parties, and assigned attorney
- **Attorney**: Represents an attorney with name and business interests

### Services
- **ConflictCollector**: Orchestrates the conflict checking process by coordinating multiple detectors across all historical matters
- **ConflictDetectors::ConflictDetector**: Base class for conflict detection algorithms
  - **ConcurrentConflictDetector**: Detects conflicts where related parties from prior matters match the prospective client
  - **LawyerClientConflictDetector**: Detects conflicts where an attorney's business interests align with a former client
  - **SuccessiveConflictDetector**: Detects conflicts where matter descriptions suggest the same client or related matter

### Controllers & Views
- **NewIntakeController**: Handles submission of new prospective matters
- **DashboardController**: Displays conflict check results and matter information


### Benefits

**For Legal Firms:**
- **Faster, safer intake**: Convert prospects into paying clients with less overhead. This immediate perceived ROI drives activation and early retention in Clio's first 90 days with that firm
- **Reduced partner-level billable labor**: Conflict-check time reduced from minutes of partner-level billable labor to seconds of assisted review
- **Compliance backbone**: Timestamped, recorded conflict clearance logs attached to each matter provide the kind of audit trail needed for compliance-grade practice management
- **Increased partner satisfaction**: Reduces the "we don't trust software to protect us" objection in sales calls
