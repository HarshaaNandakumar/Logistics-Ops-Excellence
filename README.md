# Logistics Ops Excellence

> A three-part operational governance system for freight forwarding sales & operations teams — Daily Shipment Report, Account Management tracker, and Daily Team Huddle. The system answers three questions that most branches can't: *What moved yesterday? What's stuck? What are we committed to?*

![Excel](https://img.shields.io/badge/Excel-templates-1F6F43)
![Process](https://img.shields.io/badge/discipline-operational--governance-B57E2E)
![Status](https://img.shields.io/badge/status-production--ready-success)

---

## The problem

Most freight forwarding branches run on tribal knowledge. Shipments move, emails fly, customers call — and the information lives in people's heads and their inboxes. Three specific failure modes show up again and again:

1. **No reliable daily shipment status** — The customer asks "where's my shipment?" and three different people give three different answers. The DSR (Daily Shipment Report) that goes out is late, incomplete, or never gets sent at all.
2. **Account work is opaque** — Who owns which client action? What's been done, what's pending, what's blocked? Nobody knows until something slips and a customer complains.
3. **No rhythm of execution** — Teams work hard but not together. Nobody has visibility into what each desk is handling today, what escalations are open, or whether yesterday's commitments were met.

Individually, each problem is a small annoyance. Together, they erode customer trust and make the branch fragile — performance depends entirely on which senior is in the office that week.

## The system

Three connected Excel templates that address the three failure modes directly. Each one is useful alone; together they form a daily operating cadence:

```
┌──────────────────────┐   ┌──────────────────────┐   ┌──────────────────────┐
│  1. DSR              │   │  2. AM Tracker       │   │  3. Daily Huddle     │
│  Daily Shipment      │   │  Account Management  │   │  Team stand-up       │
│  Report              │   │  Phase Tracker       │   │  Minutes & Counts    │
│                      │   │                      │   │                      │
│  What moved?         │   │  What are we         │   │  What's happening    │
│  What's stuck?       │   │  committed to?       │   │  today?              │
│  Sent daily to       │   │  Weekly review.      │   │  15-minute daily     │
│  customers.          │   │                      │   │  standup.            │
└──────────┬───────────┘   └──────────┬───────────┘   └──────────┬───────────┘
           │                          │                          │
           └──────────────┬───────────┴──────────┬───────────────┘
                          │                      │
                          ▼                      ▼
                  ┌─────────────────────────────────┐
                  │  Governance outcomes            │
                  │  • Customer visibility          │
                  │  • Account action discipline    │
                  │  • Team accountability          │
                  └─────────────────────────────────┘
```

## 1 · Daily Shipment Report (DSR)

**Purpose:** A single daily view of every shipment's status, sent to the customer and retained internally as an audit record.

### What's captured

25 fields per shipment, structured so nothing important is ever missing:

| Category | Fields |
|---|---|
| **Shipment ID** | S.No, Shipper name, JOB ID |
| **Route** | Origin, Destination, Routing |
| **Terms** | Incoterms (EXW/FCA/FOB/CFR/CIF/CPT/CIP/DAP/DPU/DDP) |
| **Container / Doc** | Master number, House number |
| **Cargo** | Pieces, Gross weight, Chargeable weight |
| **Dates** | Booking received, Pickup, ETD, ETA, ATD, ATA, Online DO release |
| **Operations** | Flight number, Completed Y/N, Booking approvers |
| **Communication** | Consignee email, CHA email, Remarks |

Incoterms and Y/N fields use **data validation dropdowns** so entries stay clean. A separate **DSR Count** sheet tracks how many reports were sent per weekday, giving the branch manager a simple compliance metric.

### Why it works

The original failure mode — "the DSR didn't go out today" — becomes impossible to hide. The count sheet creates an audit trail of send dates; the structured fields mean a new team member can be trained on it in a single session; and the fixed template means customers see the same format every day, which builds trust over time.

## 2 · Account Management Tracker

**Purpose:** A phased task tracker for everything that needs to happen on a strategic account — SOPs, contact matrices, pricing reviews, QBRs — with explicit ownership and status.

### Structure

Every action item has: **Task Name · Owner · Date Started · Date to End · Status · Notes**. Status is a controlled vocabulary (Completed / In Progress / Pending) enforced via data validation.

Tasks are grouped into **phases** so the account's progression is visible at a glance:

- **Phase I** — Foundation (SOPs, contact matrix, pricing templates)
- **Phase II** — Activation (first shipments, exception handling, initial QBR)
- **Phase III** — Growth (volume expansion, lane diversification, commercial reviews)

### Why it works

The tracker solves the "who's doing what on this account" problem that kills most KAM workflows. At any moment the account manager can answer three questions in under a minute: *What's been delivered? What's blocked on whom? What's next?* It's also a natural artefact to share with the customer during QBRs — it demonstrates thoughtful account planning without exposing internal disagreements.

## 3 · Daily Team Huddle

**Purpose:** A 15-minute morning standup that captures team workload, surfaces escalations, and creates a daily written record.

### Structure

Two linked sheets:

- **Master sheet** — Every date down the left column, every team member across the top, each cell = number of shipments that desk handled that day. Rolls up to a monthly pivot automatically. Gives the branch manager a productivity heatmap with zero extra effort.
- **Daily MoM sheet** — A per-day page capturing the minutes of the huddle: DO releases pending per desk, action items with owners and timelines, escalation notes (e.g., pending BOE amendments), shipment logs from the prior day.

### Why it works

Daily huddles without documentation are just meetings. Documented huddles become the branch's operating heartbeat — you can look back six months and see exactly what was being discussed, what was promised, and whether it got done. The monthly pivot also quietly creates a capacity-planning tool: if Desk 4 handled 56 files in January and 15 in February, something changed and the data invites the conversation.

## How the three pieces reinforce each other

- The **DSR** surfaces operational issues; those issues get logged as **huddle** action items
- Huddle actions that are bigger than a single day get elevated to the **AM Tracker** as formal account tasks
- AM Tracker completions feed back into customer-facing **QBR** conversations, driven by data the DSR already captures

The system is designed so that filling in one tool naturally populates context for the others — no duplicate data entry, just different views on the same daily operational reality.

## Repo contents

```
logistics-ops-excellence/
├── README.md                               ← you are here
├── templates/
│   ├── DSR_Template.xlsx                   ← Daily Shipment Report (DSR + DSR Count + Outlook Log)
│   ├── AM_Tracker_Template.xlsx            ← Phase tracker + live summary + phase calendar
│   └── Daily_Huddle_Template.xlsx          ← Master counts + Daily MoM template
├── src/
│   └── DSR_Outlook_Log.bas                 ← VBA: auto-pull DSR emails from Outlook
└── docs/
    ├── DSR_FIELD_GUIDE.md                  ← what each of the 25 fields means
    ├── AM_TRACKER_PLAYBOOK.md              ← how to run a phased account plan
    └── HUDDLE_OPERATING_RHYTHM.md          ← how to run a 15-min huddle that doesn't suck
```

## How to use

Each template is self-contained — download, customize for your branch, use. The docs in `/docs/` explain the *intent* behind each field and how to run the process, not just the mechanics.

For a new branch or team implementing all three, the recommended rollout order is:

1. **Week 1** — Daily Huddle. Cheapest to start, highest immediate payoff, builds team rhythm.
2. **Week 2–3** — DSR. Once the huddle is discussing shipment status daily, formalizing the DSR format becomes obvious.
3. **Week 4+** — AM Tracker. Only useful once the first two are running, because it depends on daily operational signal to stay current.

## Outcomes in production

Deployed on a freight forwarding branch with five operations desks and a strategic account portfolio:

- **100% DSR compliance** on priority customers within 30 days of rollout (previously ad-hoc)
- **~75 DSRs per month** logged with send-date audit trail
- **Monthly desk productivity** became visible for the first time — enabled rebalancing conversations that were previously impossible
- **Account actions tracked against phase milestones** rather than living in email chains

## Case study context

Built and deployed during my role as Strategic Account & Analytics Manager at a global freight forwarding company. All customer names, team member names, and specific shipment data in this repo have been anonymized; the structures, field designs, and operating cadences are original.

---

<sub>Part of my [supply chain analytics portfolio](https://harshaanandakumar.github.io) · Built by [Harshaa Nandakumar](https://www.linkedin.com/in/harshaanandakumar/)</sub>
