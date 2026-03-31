<div align="center">

# 🛡️ Auditor Core v2.2

## Deterministic Security Intelligence Layer

[![License](https://img.shields.io/badge/license-Commercial-red.svg)](TERMS_OF_USE.md)
[![Python](https://img.shields.io/badge/python-3.10%2B-blue.svg)](https://python.org)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)]()
[![Status](https://img.shields.io/badge/status-Production%20Ready-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/version-2.2-blue.svg)]()

*Engineering-grade signal. Not an alarm counter.*

**[🌐 Website](https://datawizual.github.io) · [📧 Get License](mailto:eldorzufarov66@gmail.com)**

---

![Auditor Core Demo](demo.gif)

</div>

---

## The Problem

Standard security tools such as Bandit, Semgrep, and Gitleaks generate large volumes of disconnected alerts.
Without context, these findings are difficult to prioritize and often lead to alert fatigue, wasted engineering time, and missed critical risks.

---

## The Solution

Auditor Core is a deterministic security auditing engine that transforms raw detection signals into a unified, context-aware security model.

It ingests findings from multiple detection engines and:

* Correlates and deduplicates overlapping results
* Adds architectural context to distinguish between core logic and infrastructure
* Applies weighted risk modeling using WSPM v2.2
* Maps every finding to SOC 2 Trust Services Criteria, CIS Controls v8, and ISO/IEC 27001:2022 Annex A
* Generates professional-grade PDF reports suitable for SOC 2 readiness engagements and cyber insurance underwriting

This results in a structured view of actual security risk instead of isolated alerts.

---

## The Math Behind the Risk

Auditor Core computes a reproducible security posture score using the following model:

$$
SPI = 100 \cdot e^{-\frac{\sum \text{WeightedExposure}}{K}}
$$

The Security Posture Index (SPI) accounts for:

* Location of issues — production and infrastructure findings only (test files and docs excluded)
* Confidence across detection engines
* Exposure and reachability of findings
* Per-rule exposure cap to prevent score distortion from a single noisy detector
* Scaling factor (K) for consistency across project sizes

> **Gate Override (v2.2):** If CRITICAL findings exist in production code, the effective grade is capped at C — regardless of the mathematical SPI. This resolves the cognitive dissonance of a high SPI alongside a FAIL decision for CISO and underwriter audiences.

---

## Output (ROI)

Auditor Core translates findings into actionable outputs:

| SPI    | Grade | Status            | Action                      |
| ------ | ----- | ----------------- | --------------------------- |
| 90–100 | A     | Resilient         | Audit-ready                 |
| 70–89  | B     | Guarded           | Monitor and schedule fixes  |
| 40–69  | C     | Elevated Risk     | Prioritize remediation      |
| 0–39   | D     | Critical Exposure | Immediate response required |

---

## Integration

Auditor Core outputs three report formats per scan:

* **PDF Executive Summary** — 7-page audit-ready document for SOC 2 readiness and cyber insurance underwriting (Marsh, Aon, At-Bay, Coalition). Includes evidence appendix with source-level code context for every CRITICAL/HIGH finding, remediation roadmap, and attestation block with signature lines.
* **Interactive HTML Report** — Enterprise posture dashboard with SOC 2 / CIS / ISO 27001 control tags, AI analysis, and reachability breakdown. Suitable for engineering teams.
* **Machine-readable JSON** — CI/CD gating with `instance_count`, `instance_lines`, `compliance_mapping` per finding and `framework_summary` block for direct SIEM integration.
* **AI-driven analysis** — Gemini 2.5 Flash with automatic Groq fallback (zero interruption on quota).

### Compliance Framework Coverage

Every finding is automatically mapped to:

| Framework | Standard |
|---|---|
| SOC 2 TSC | CC6.1, CC6.6, CC7.1, CC8.1 and more |
| CIS Controls v8 | CIS-16.1, CIS-16.12, CIS-3.11 and more |
| ISO/IEC 27001:2022 | A.8.28, A.8.26, A.5.17 and more |

Reports include a `framework_summary` block aggregating which controls are triggered across all findings — ready for direct submission to SOC 2 auditors or cyber insurance underwriters.

> This report does not constitute a formal SOC 2 audit opinion.
> For SOC 2 Type I/II certification, engage a licensed CPA firm.

---

## Installation

### Step 1 — Get Your License Key

Each installation is hardware-bound. Retrieve your Machine ID:

```bash
python3 -c "from auditor.security.guard import AuditorGuard; print(AuditorGuard().get_machine_id())"
```

Send the Machine ID to **eldorzufarov66@gmail.com** to receive your License Key.

> ⚠️ Each License Key is cryptographically bound to a specific machine.

### Step 2 — Extract and Install

You will receive a `.zip` archive. Extract it to any directory you prefer:

```bash
unzip auditor-core-<version>.zip
cd auditor-core
bash start.sh
```

`start.sh` will guide you through setup interactively:

1. **Accept Terms of Use** — type `YES` to proceed
2. **Enter your License Key** — provided after Step 1
3. **Set a database password** — choose any secure password
4. **Enter your Google Gemini API Key** — for AI-assisted analysis
5. **Enter your Groq API Key** — optional fallback AI (press Enter to skip)

After that, `start.sh` handles the rest automatically:
- Starts PostgreSQL via Docker Compose
- Creates Python virtual environment
- Installs all dependencies
- Makes `./audit` executable

### Step 3 — Run

```bash
./audit /path/to/your/project
```

Reports are saved to `reports/`:
```
reports/
├── report_<project>.pdf    ← Executive Summary (SOC 2 / cyber insurance ready)
├── report_<project>.html   ← Interactive Enterprise Posture Report
└── report_<project>.json   ← Machine-readable findings with compliance mapping
```

---

## Configuration

All scanning behavior is controlled via `audit-config.yml`:

```yaml
scanner:
  max_findings: 5000
  scan_tests: false
  exclude:
    - "**/venv/**"
    - "**/node_modules/**"

detectors:
  semgrep_detector: true
  bandit_detector: true
  gitleaks_detector: true
  iac_scanner: true
  dependency_scanner: true
  cicd_analyzer: true
  license_scanner: true

reporting:
  formats: ["html", "json", "pdf"]
  output_dir: "reports"

policy:
  fail_on_severity: "HIGH"
  min_severity: "LOW"

ai:
  enabled: true
  mode: "external"
  external:
    provider: "google"
    model: "gemini-2.5-flash"
```

---

## Requirements

| Component | Version |
|---|---|
| Python | 3.10+ |
| Docker | Required (PostgreSQL) |
| OS | Linux / macOS |
| reportlab | Required (PDF generation) |
| Gemini API | Optional (AI advisory) |
| Groq API | Optional (fallback) |

---

## What's New in v2.2

* **PDF Evidence Appendix** — source-level code context for every CRITICAL/HIGH finding, audit-defensible out of the box
* **SOC 2 / CIS / ISO 27001 mapping** — every finding tagged to specific controls; `framework_summary` in JSON
* **Gate Override** — effective grade capped at C when CRITICAL findings exist in production, regardless of SPI
* **Context Intelligence** — `NON_RUNTIME` context (test/, docs/, examples/ prefixes) excluded from SPI by default; detector fixture files recognised as `SETUP`
* **Duplicate aggregation** — multiple findings in the same file shown as one block with line list in PDF
* **Unified assessment language** — consistent verdict labels across PDF and HTML formats
* **NUL-byte sanitization** — binary files no longer cause database errors
* **Delivery packaging** — Cython-compiled `.so` distribution for IP protection

---

## FAQ

**Does Auditor Core send data anywhere?**
No. Fully offline operation. The only outbound connection is to the AI API if explicitly configured.

**What if Gemini API quota is exceeded?**
Auditor Core automatically switches to Groq (llama-3.3-70b-versatile) as fallback. Zero interruption.

**Can the PDF report be used for SOC 2 readiness?**
Yes — as supporting evidence for pre-assessment and gap analysis. It does not constitute a formal audit opinion. For SOC 2 Type I/II certification, engage a licensed CPA firm.

**Can the PDF report be submitted to cyber insurance underwriters?**
Yes. The report format is designed to align with underwriting pre-assessment requirements from Marsh, Aon, At-Bay, and Coalition.

**How is Auditor Core different from Sentinel Core?**
Auditor Core v2.2 is a deep audit engine — run on demand for comprehensive posture reports. [Sentinel Core](https://datawizual.github.io) is a real-time enforcement gate that intercepts every commit. Sentinel uses Auditor Core internally as its scanning engine.

**Can I integrate JSON output into my SIEM?**
Yes. The JSON report is designed for downstream integration with SIEM platforms, dashboards, and CI/CD quality gates.

---

## Support

📧 **eldorzufarov66@gmail.com**

Please include: Machine ID · OS version · Python version · `last_api_debug.txt` if applicable.

---

<div align="center">

© 2026 DataWizual Security Labs. All rights reserved.

Use governed by [TERMS_OF_USE.md](TERMS_OF_USE.md)

</div>