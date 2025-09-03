# Pipeline Customization Guide

## Adapting to Your Technology Stack

### Python Projects
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "if [[ \"${file_path}\" =~ \\.py$ ]]; then black \"${file_path}\" && pylint \"${file_path}\" --errors-only || true; fi"
      }]
    }]
  }
}
```

### Go Projects  
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write", 
      "hooks": [{
        "type": "command",
        "command": "if [[ \"${file_path}\" =~ \\.go$ ]]; then gofmt -w \"${file_path}\" && go vet \"${file_path}\" || true; fi"
      }]
    }]
  }
}
```

### Java Projects
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "if [[ \"${file_path}\" =~ \\.java$ ]]; then google-java-format --replace \"${file_path}\" && checkstyle -c checkstyle.xml \"${file_path}\" || true; fi"
      }]
    }]
  }
}
```

## Agent Customization

### Custom Code Standards
Modify `.claude/agents/code-quality-enforcer.md`:

```markdown
## Quality Standards

**Always Check:**
- [ ] Your custom standards here
- [ ] Company-specific patterns
- [ ] Domain-specific validations

**Avoid:**
- Anti-patterns specific to your codebase
- Legacy patterns being phased out
```

### Domain-Specific Agents
Create specialized agents for your domain:

```markdown
---
name: fintech-compliance-checker
description: Financial services compliance and regulation checker
tools: Read, Grep, Glob, WebFetch
---

# FinTech Compliance Checker

Check for:
- PCI DSS compliance
- SOX requirements  
- Data encryption standards
- Audit trail requirements
```

## Team Integration

### Shared Configuration
Store team configuration in version control:
```bash
# .claude/settings.team.json
{
  "_team": "Your Team Name",
  "_standards": "https://your-company.com/coding-standards",
  "hooks": {
    // Team standard hooks
  }
}
```

### Gradual Rollout
1. **Week 1**: Basic formatting hooks only
2. **Week 2**: Add linting and basic testing
3. **Week 3**: Include security validations
4. **Week 4**: Full agent integration

## Performance Tuning

### Hook Optimization
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "if [[ \"${file_path}\" =~ ^src/.*\\.(js|ts)$ ]] && [[ $(wc -l < \"${file_path}\") -lt 1000 ]]; then npm run lint:quick \"${file_path}\"; fi"
      }]
    }]
  }
}
```

### Agent Scope Limiting
```yaml
---
tools: Read, Grep  # Limit to essential tools only
---

# Focused Agent

Before analysis:
1. Check file size: skip files > 500 lines for quick feedback
2. Focus on changed sections only
3. Prioritize critical issues over suggestions
```

## Metrics and Monitoring

### Custom Metrics
```bash
# Add to hooks
"command": "echo \"$(date)|${tool}|${file_path}|$(your_custom_metric)\" >> ~/.claude/custom-metrics.log"
```

### Dashboard Integration
```javascript
// metrics-dashboard.js
const metrics = parseMetricsLog();
const dashboard = {
  dailyActivity: calculateDailyActivity(metrics),
  qualityTrends: calculateQualityTrends(metrics),
  teamProductivity: calculateTeamMetrics(metrics)
};
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Claude Quality Check
on: [pull_request]
jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Claude Code
        run: |
          # Install Claude Code
          # Copy .claude configuration
      - name: Run Quality Pipeline
        run: |
          ./scripts/validate-agents.sh
          ./scripts/test-pipeline.sh
```

### Jenkins Pipeline
```groovy
pipeline {
  agent any
  stages {
    stage('Quality Check') {
      steps {
        sh './scripts/test-pipeline.sh'
      }
    }
  }
}
```