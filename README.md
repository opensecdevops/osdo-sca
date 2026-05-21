# osdo-sca

> Part of the [OSDO Framework](https://github.com/opensecdevops/osdo) — Open SecDevOps

Software Composition Analysis — Scan dependencies for vulnerabilities using OSV-Scanner, Grype, and native package managers

## Quick Start

```yaml
- uses: opensecdevops/osdo-sca@v2
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `path` | Path to scan for dependency vulnerabilities | No | `.` |
| `manifest-file` | Dependency manifest file (auto-detect if not specified) | No | `""` |
| `scanners` | Scanners to use (osv, grype, native, all) | No | `osv` |
| `severity-threshold` | Minimum severity to report (LOW, MEDIUM, HIGH, CRITICAL) | No | `MEDIUM` |
| `fail-on-critical` | Fail the action if critical vulnerabilities are found | No | `true` |
| `fail-on-high` | Fail the action if high severity vulnerabilities are found | No | `false` |
| `ignore-unfixed` | Ignore vulnerabilities without fixes available | No | `false` |
| `results-dir` | Directory to store results | No | `.osdo/results` |

## Outputs

| Output | Description |
|--------|-------------|
| `findings` | Total vulnerable dependencies found |
| `critical-count` | Critical vulnerabilities count |
| `high-count` | High vulnerabilities count |
| `package-manager` | Detected package manager |

## Example

```yaml
name: Security Scan
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: opensecdevops/osdo-sca@v2
        with:
          path: "."
          manifest-file: "package-lock.json"
          scanners: "osv,grype"
          severity-threshold: "HIGH"
          fail-on-critical: "true"
          fail-on-high: "false"
          ignore-unfixed: "false"
```

## Part of OSDO

This action is part of the [OSDO Framework](https://github.com/opensecdevops/osdo). Use it standalone or combine with other OSDO actions:

- [osdo-sast](https://github.com/opensecdevops/osdo-sast) — Static Analysis
- [osdo-sca](https://github.com/opensecdevops/osdo-sca) — Dependency Scanning
- [osdo-secrets-scan](https://github.com/opensecdevops/osdo-secrets-scan) — Secret Detection
- [osdo-container-scan](https://github.com/opensecdevops/osdo-container-scan) — Container Security
- [osdo-iac-scan](https://github.com/opensecdevops/osdo-iac-scan) — IaC Scanning
- [osdo-sbom](https://github.com/opensecdevops/osdo-sbom) — SBOM Generation
- [osdo-sign](https://github.com/opensecdevops/osdo-sign) — Artifact Signing

## License

Apache-2.0
