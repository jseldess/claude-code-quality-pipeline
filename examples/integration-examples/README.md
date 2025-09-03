# Integration Pattern Examples

This directory contains examples of how to integrate the Quality Pipeline with other development workflows and patterns.

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/claude-quality.yml
name: Claude Code Quality Check

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main ]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Setup Claude Code Quality Pipeline
      run: |
        # Install Claude Code (replace with actual installation method)
        curl -sSL https://claude.ai/install | bash
        
        # Copy pipeline configuration
        cp .claude/settings.local.json.template .claude/settings.local.json
        
        # Validate configuration
        npm run validate-pipeline
    
    - name: Run Quality Pipeline Tests
      run: |
        chmod +x scripts/test-pipeline.sh
        ./scripts/test-pipeline.sh
    
    - name: Generate Quality Report
      run: |
        chmod +x scripts/metrics-collector.sh
        ./scripts/metrics-collector.sh
        
        # Upload report as artifact
        echo "## Quality Pipeline Report" >> $GITHUB_STEP_SUMMARY
        cat quality-pipeline-report.txt >> $GITHUB_STEP_SUMMARY
    
    - name: Upload Quality Metrics
      uses: actions/upload-artifact@v3
      with:
        name: quality-metrics
        path: |
          quality-pipeline-report.txt
          ~/.claude/quality-metrics.log
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        NODE_VERSION = '18'
        CLAUDE_CONFIG_DIR = '.claude'
    }
    
    stages {
        stage('Setup') {
            steps {
                // Install Node.js
                sh 'nvm install $NODE_VERSION && nvm use $NODE_VERSION'
                
                // Install dependencies
                sh 'npm ci'
                
                // Setup Claude Code Quality Pipeline
                sh '''
                    # Install Claude Code
                    curl -sSL https://claude.ai/install | bash
                    
                    # Configure pipeline
                    cp .claude/settings.local.json.template .claude/settings.local.json
                '''
            }
        }
        
        stage('Quality Pipeline Test') {
            steps {
                sh '''
                    chmod +x scripts/test-pipeline.sh
                    ./scripts/test-pipeline.sh
                '''
            }
        }
        
        stage('Generate Report') {
            steps {
                sh '''
                    chmod +x scripts/metrics-collector.sh
                    ./scripts/metrics-collector.sh
                '''
                
                // Archive artifacts
                archiveArtifacts artifacts: 'quality-pipeline-report.txt', fingerprint: true
            }
        }
    }
    
    post {
        always {
            // Clean up
            sh 'rm -f ~/.claude/quality-metrics.log'
        }
        success {
            echo 'Quality pipeline passed!'
        }
        failure {
            echo 'Quality pipeline failed. Check the logs.'
        }
    }
}
```

## Docker Integration

### Dockerfile for Development Environment

```dockerfile
# Dockerfile.dev
FROM node:18-alpine

# Install Claude Code
RUN curl -sSL https://claude.ai/install | bash

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy Claude configuration
COPY .claude/ .claude/

# Copy source code
COPY . .

# Setup quality pipeline
RUN chmod +x scripts/*.sh
RUN ./scripts/test-pipeline.sh

# Expose port
EXPOSE 3000

# Development command with quality pipeline active
CMD ["npm", "run", "dev"]
```

### Docker Compose for Team Development

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
      - claude-metrics:/root/.claude
    environment:
      - NODE_ENV=development
      - CLAUDE_PIPELINE_ACTIVE=true
    command: |
      sh -c "
        echo 'Starting development environment with Claude Quality Pipeline...'
        ./scripts/test-pipeline.sh
        npm run dev
      "

volumes:
  claude-metrics:
```

## Team Workflow Integration

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running Claude Code Quality Pipeline..."

# Check if pipeline is available
if ! command -v claude &> /dev/null; then
    echo "⚠️ Claude Code not found. Install from https://claude.ai/code"
    echo "Commit allowed but quality pipeline not run."
    exit 0
fi

# Run pipeline validation
if [ -f "scripts/test-pipeline.sh" ]; then
    chmod +x scripts/test-pipeline.sh
    if ! ./scripts/test-pipeline.sh; then
        echo "❌ Quality pipeline validation failed."
        echo "Fix issues before committing or use --no-verify to bypass."
        exit 1
    fi
else
    echo "⚠️ Quality pipeline test script not found."
fi

echo "✅ Quality pipeline validation passed."
exit 0
```

### VS Code Integration

```json
{
  "settings": {
    "claude-code.pipeline.autoRun": true,
    "claude-code.agents.available": [
      "code-quality-enforcer",
      "review-coordinator", 
      "security-scanner"
    ]
  },
  "tasks": {
    "version": "2.0.0",
    "tasks": [
      {
        "label": "Claude: Run Quality Pipeline",
        "type": "shell",
        "command": "./scripts/test-pipeline.sh",
        "group": "test",
        "presentation": {
          "echo": true,
          "reveal": "always",
          "focus": false,
          "panel": "shared"
        },
        "problemMatcher": []
      },
      {
        "label": "Claude: Generate Metrics Report",
        "type": "shell", 
        "command": "./scripts/metrics-collector.sh",
        "group": "build",
        "presentation": {
          "echo": true,
          "reveal": "always",
          "focus": false,
          "panel": "shared"
        }
      }
    ]
  }
}
```

## Slack Integration

### Quality Report Bot

```javascript
// slack-bot.js
const { WebClient } = require('@slack/web-api');
const fs = require('fs');

const slack = new WebClient(process.env.SLACK_BOT_TOKEN);

async function sendQualityReport() {
  try {
    // Generate metrics report
    const { execSync } = require('child_process');
    execSync('./scripts/metrics-collector.sh');
    
    // Read report
    const report = fs.readFileSync('quality-pipeline-report.txt', 'utf8');
    
    // Send to Slack
    await slack.chat.postMessage({
      channel: '#dev-quality',
      text: 'Daily Quality Pipeline Report',
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: '📊 Daily Quality Report'
          }
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `\`\`\`${report}\`\`\``
          }
        }
      ]
    });
    
    console.log('Quality report sent to Slack');
  } catch (error) {
    console.error('Failed to send report:', error);
  }
}

// Run daily at 9 AM
if (require.main === module) {
  sendQualityReport();
}
```

### Hook for Real-time Notifications

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"${file_path}\" =~ (critical|security|auth) ]]; then curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"🚨 Critical file modified: ${file_path} by $(whoami)\"}' $SLACK_WEBHOOK_URL 2>/dev/null || true; fi"
          }
        ]
      }
    ]
  }
}
```

## Monitoring Integration

### Prometheus Metrics

```bash
#!/bin/bash
# metrics-exporter.sh

METRICS_FILE="$HOME/.claude/quality-metrics.log"
PROMETHEUS_FILE="/var/lib/prometheus/node-exporter/claude_quality.prom"

# Export metrics in Prometheus format
cat > "$PROMETHEUS_FILE" << EOF
# HELP claude_quality_operations_total Total number of quality pipeline operations
# TYPE claude_quality_operations_total counter
claude_quality_operations_total $(wc -l < "$METRICS_FILE")

# HELP claude_quality_files_processed_total Total number of unique files processed
# TYPE claude_quality_files_processed_total counter
claude_quality_files_processed_total $(cut -d'|' -f3 "$METRICS_FILE" | sort -u | wc -l)

# HELP claude_quality_operations_today Operations performed today
# TYPE claude_quality_operations_today gauge
claude_quality_operations_today $(grep "$(date '+%Y-%m-%d')" "$METRICS_FILE" | wc -l)
EOF
```

### Grafana Dashboard Configuration

```json
{
  "dashboard": {
    "title": "Claude Code Quality Pipeline",
    "panels": [
      {
        "title": "Daily Operations",
        "type": "graph",
        "targets": [
          {
            "expr": "claude_quality_operations_today"
          }
        ]
      },
      {
        "title": "Total Files Processed", 
        "type": "stat",
        "targets": [
          {
            "expr": "claude_quality_files_processed_total"
          }
        ]
      }
    ]
  }
}
```

## Testing Integration

### Jest Configuration for Pipeline Testing

```javascript
// jest.pipeline.config.js
module.exports = {
  displayName: 'Claude Pipeline Tests',
  testMatch: ['**/pipeline-tests/**/*.test.js'],
  setupFilesAfterEnv: ['<rootDir>/pipeline-tests/setup.js'],
  testEnvironment: 'node'
};
```

### Pipeline Test Suite

```javascript
// pipeline-tests/quality-pipeline.test.js
describe('Claude Quality Pipeline', () => {
  test('agents are properly configured', async () => {
    const agents = ['code-quality-enforcer', 'review-coordinator'];
    
    for (const agent of agents) {
      const agentFile = `.claude/agents/${agent}.md`;
      expect(fs.existsSync(agentFile)).toBe(true);
      
      const content = fs.readFileSync(agentFile, 'utf8');
      expect(content).toContain(`name: ${agent}`);
      expect(content).toContain('tools:');
    }
  });
  
  test('hooks configuration is valid', () => {
    const config = JSON.parse(fs.readFileSync('.claude/settings.local.json', 'utf8'));
    expect(config.hooks).toBeDefined();
    expect(config.hooks.PostToolUse).toBeDefined();
  });
});
```