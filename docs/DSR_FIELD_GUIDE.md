# DSR Field Guide

What each of the 25 fields captures, and why it's there.

The DSR exists to answer one question the customer asks every day: *"Where is my shipment?"* Every field is there because its absence, at some point, caused a customer to ask a follow-up question that the team couldn't immediately answer.

---

## Shipment identification

**S.No** — Sequential row number within the DSR. Resets each day. Useful only for in-meeting reference ("can we discuss line 4?").

**Shipper Name** — The customer being served. Matches the name the customer's ops team uses for themselves, not internal account codes.

**JOB ID** — The forwarder's internal reference for the shipment. Format should be consistent across the branch; our default assumes `[OriginCode]JOB[Sequence]`, e.g., `MAAJOB001`.

## Route

**Origin** — IATA/port code of the origin. Always a code, never a city name, to avoid ambiguity (Chennai has both MAA airport and MAA port).

**Destination** — IATA/port code of the final destination.

**Routing** — The actual path the shipment takes. For direct shipments this duplicates origin/destination; for transshipments it exposes the intermediate hub (e.g., `MAA-FRA via DXB`).

## Commercial terms

**Incoterm** — One of the 11 Incoterms 2020: EXW, FCA, FOB, CFR, CIF, CPT, CIP, DAP, DPU, DDP. Enforced via dropdown. This field is important because it determines who pays which charges — confusion here is the most common cause of billing disputes.

## Container & documentation

**Master Number** — The bill of lading (sea) or master airway bill (air) issued by the carrier. This is the carrier's reference.

**House Number** — The forwarder's house bill of lading / house airway bill. This is the document given to the shipper.

## Cargo

**No. of Pieces** — How many cartons, pallets, or packages. Straightforward.

**Gross Wt (kg)** — Actual physical weight in kilograms.

**Chargeable Wt (kg)** — The weight used for billing. For air freight this is `max(gross weight, volumetric weight)` where volumetric = `L × W × H / 6000` in cm. For sea freight this is typically the gross weight or CBM-based, depending on the carrier.

## Dates — the core of the DSR

These six fields are the operational heartbeat. Every customer question about shipment status maps to one of them.

**Booking Received** — The date the forwarder received the booking from the shipper. The clock starts here.

**Pickup Date** — When the cargo was physically picked up from the shipper. For FCL this is often when the empty container was stuffed and returned to the yard.

**Flight No.** — The flight number (air) or vessel + voyage (sea). Left blank until the booking is confirmed with the carrier.

**ETD** — Estimated Time of Departure. What the carrier plans.

**ETA** — Estimated Time of Arrival at destination. What the carrier plans.

**ATD** — Actual Time of Departure. Populated once the shipment actually leaves.

**ATA** — Actual Time of Arrival. Populated once the shipment actually arrives.

**DO Release** — When the Delivery Order was released at destination (online or manual). Critical milestone — the consignee cannot collect cargo without it.

> The discipline: never confuse ETD/ETA with ATD/ATA. If you're telling a customer the shipment "departed," you must have a source (carrier confirmation, tracking update) that justifies moving the date from the E column to the A column.

## Operations

**Completed (Y/N)** — Has the shipment fully concluded? Y means: cargo delivered, all documents closed, no pending issues. Anything else = N. Enforced via dropdown.

**Booking Approvers** — Who internally approved the booking. Useful for audit trail and for knowing who to escalate to.

## Communication

**Consignee Email** — Primary contact at destination. The person who cares whether the cargo arrives on time.

**CHA Email** — The Customs House Agent at destination. The person who clears the cargo.

**Remarks** — Free text. Kept short. If a shipment needs more than a sentence of explanation, the conversation belongs in an email chain referenced here, not crammed into this cell.

---

## What the DSR intentionally doesn't capture

- **Rate / cost data** — Pricing is not in the DSR. Keeping commercial info out means the DSR can be shared with operations-only contacts at the customer without exposing margins.
- **Internal escalation notes** — If something is going wrong internally, that goes in the daily huddle MoM. The DSR is the customer-facing artifact.
- **Multiple customer-specific fields** — Some customers will ask for extra columns (PO numbers, internal reference codes, cost centers). Those get added to a customer-specific variant of the DSR, not to the master template.

## Standard update cadence

- **Morning (before huddle)** — Update ATD/ATA/DO Release for anything that moved overnight
- **Mid-day** — Add new bookings received that morning
- **End of day** — Final review, mark Completed = Y for closed shipments, send to customer

The DSR goes out once per day, typically by EOD, covering every active shipment. The "DSR Count" sheet tracks whether the send happened — **automatically**, via the Outlook Log.

---

## The Outlook Log + Working-Days Compliance System

The weakest point of any DSR process is the send itself. People forget. People get busy. Manually ticking a Y/N box to confirm you sent the DSR is exactly the kind of task that falls through the cracks first.

The template solves this with three connected sheets:

### How it works

```
┌─────────────────────┐      ┌─────────────────────┐      ┌─────────────────────┐
│  You send an email  │      │  VBA reads Outlook  │      │  DSR Count marks    │
│  with subject       │  →   │  and writes every   │  →   │  that day's row     │
│  "DSR #..."         │      │  match to Outlook   │      │  as Y automatically │
│                     │      │  Log sheet          │      │                     │
└─────────────────────┘      └─────────────────────┘      └─────────────────────┘
```

### The DSR Count sheet

Lists every **working day** (Monday through Saturday — Sundays are excluded, since DSRs are not expected on non-working days). Three columns:

- **Date** — sequential working days
- **Weekday** — text label for quick visual scan
- **DSR Sent (Y/N)** — a `COUNTIFS` formula that checks the Outlook Log for any entry on that date:

```excel
=IF(COUNTIFS('Outlook Log'!C:C, ">="&B4, 'Outlook Log'!C:C, "<"&(B4+1)) > 0, "Y", "N")
```

On the right side of the sheet, live metrics: Working Days, DSRs Sent, DSRs Missed, and Compliance %.

### The Outlook Log sheet

Auto-populated by the VBA macro `RefreshOutlookLog` (in `src/DSR_Outlook_Log.bas`). When clicked, it:

1. Connects to the user's Outlook
2. Scans Sent Items and Inbox for the last 60 days (configurable)
3. Filters to messages where the subject contains `DSR` (case-insensitive)
4. Writes each match to the log with five fields:

| Column | Content |
|---|---|
| Subject | e.g., `DSR #20260117 - Customer A` |
| Sender | e.g., `harshaa@forwarder.com` |
| Timestamp | `SentOn` for outgoing, `ReceivedTime` for incoming |
| Direction | `Sent` (green) or `Received` (amber) |
| Recipient(s) | Semicolon-separated addresses |

5. Sorts newest-first

### Why scanning Inbox too (not just Sent)

Pulling received DSR replies gives a useful side-benefit: the log becomes a conversation trail. If a customer writes back to a DSR with a question, that reply shows up in the log alongside the original send. Over time this creates an audit trail of customer engagement on DSRs — useful for QBR prep and escalation investigations.

### Subject-line discipline

For the automation to work, the subject must contain the string `DSR`. The suggested format is:

```
DSR #YYYYMMDD - [Customer / Daily]
```

Examples:
- `DSR #20260117 - Daily`
- `DSR #20260117 - Customer A`
- `DSR #20260117 - Priority Shipments`

Any subject containing `DSR` matches — the filter is intentionally broad so that reply threads (`RE: DSR #20260117`) and forwards also appear in the log.

### Setup

See the Read Me sheet inside the template — the one-time setup is:

1. Save the workbook as `.xlsm` (macro-enabled)
2. Import `src/DSR_Outlook_Log.bas` via the VBA editor
3. Run `AddRefreshButton` once to install the button on the Outlook Log sheet
4. Click the button daily (or weekly) to refresh

First run will prompt Outlook to grant programmatic access — approve it. Subsequent runs are silent.
