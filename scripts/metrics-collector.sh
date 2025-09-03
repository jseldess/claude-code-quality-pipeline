#!/bin/bash

METRICS_FILE="$HOME/.claude/quality-metrics.log"
REPORT_FILE="quality-pipeline-report.txt"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📊 Generating Quality Pipeline Metrics Report...${NC}"

if [[ ! -f "$METRICS_FILE" ]]; then
    echo -e "${YELLOW}⚠️ No metrics file found at $METRICS_FILE${NC}"
    echo "Run the pipeline first to generate metrics, or check if the file location is correct."
    exit 1
fi

# Generate report
cat > "$REPORT_FILE" << EOF
# Quality Pipeline Metrics Report
Generated: $(date)
Metrics file: $METRICS_FILE

## Pipeline Activity Summary
Total operations: $(wc -l < "$METRICS_FILE")
Files processed: $(cut -d'|' -f3 "$METRICS_FILE" | sort -u | wc -l)
Most recent activity: $(tail -1 "$METRICS_FILE" | cut -d'|' -f1)

EOF

# Check if we have enough data
TOTAL_LINES=$(wc -l < "$METRICS_FILE")
if [ "$TOTAL_LINES" -lt 1 ]; then
    echo "No activity recorded yet." >> "$REPORT_FILE"
else
    # File type breakdown
    echo "## File Types Processed" >> "$REPORT_FILE"
    echo "### Breakdown by File Extension" >> "$REPORT_FILE"
    cut -d'|' -f3 "$METRICS_FILE" | sed 's/.*\.//' | grep -E '\w+' | sort | uniq -c | sort -nr | head -10 >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
    echo "## Tool Usage Statistics" >> "$REPORT_FILE"
    cut -d'|' -f2 "$METRICS_FILE" | sed 's/^ *//' | sort | uniq -c | sort -nr >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
    echo "## Daily Activity (Last 7 Days)" >> "$REPORT_FILE"
    
    # Get last 7 days of activity
    for i in {0..6}; do
        DATE=$(date -d "$i days ago" '+%Y-%m-%d' 2>/dev/null || date -v-${i}d '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d')
        COUNT=$(grep "$DATE" "$METRICS_FILE" | wc -l)
        echo "$DATE: $COUNT operations" >> "$REPORT_FILE"
    done

    echo "" >> "$REPORT_FILE"
    echo "## Most Active Files" >> "$REPORT_FILE"
    cut -d'|' -f3 "$METRICS_FILE" | sort | uniq -c | sort -nr | head -10 >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
    echo "## Recent Activity (Last 10 Operations)" >> "$REPORT_FILE"
    tail -10 "$METRICS_FILE" >> "$REPORT_FILE"

    # Performance metrics if available
    echo "" >> "$REPORT_FILE"
    echo "## Performance Insights" >> "$REPORT_FILE"
    
    # Average file size
    TOTAL_LINES_PROCESSED=$(cut -d'|' -f4 "$METRICS_FILE" | grep -o '[0-9]\+' | awk '{sum += $1} END {print sum}')
    if [ -n "$TOTAL_LINES_PROCESSED" ] && [ "$TOTAL_LINES_PROCESSED" -gt 0 ]; then
        AVG_LINES=$((TOTAL_LINES_PROCESSED / TOTAL_LINES))
        echo "Average file size: $AVG_LINES lines" >> "$REPORT_FILE"
    fi
    
    # Files processed per day (if we have recent data)
    TODAY_COUNT=$(grep "$(date '+%Y-%m-%d')" "$METRICS_FILE" | wc -l)
    echo "Files processed today: $TODAY_COUNT" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "## Configuration Status" >> "$REPORT_FILE"
if [ -f ".claude/settings.local.json" ]; then
    echo "✅ Hook configuration active" >> "$REPORT_FILE"
else
    echo "❌ No hook configuration found" >> "$REPORT_FILE"
fi

if [ -d ".claude/agents" ]; then
    AGENT_COUNT=$(ls .claude/agents/*.md 2>/dev/null | wc -l)
    echo "✅ $AGENT_COUNT agents configured" >> "$REPORT_FILE"
else
    echo "❌ No agents directory found" >> "$REPORT_FILE"
fi

echo -e "${GREEN}✅ Report generated: $REPORT_FILE${NC}"
echo ""
cat "$REPORT_FILE"

# Optionally create a summary for quick viewing
echo -e "\n${BLUE}📈 Quick Summary:${NC}"
echo "Total operations: $TOTAL_LINES"
echo "Unique files: $(cut -d'|' -f3 "$METRICS_FILE" | sort -u | wc -l)"
echo "Today's activity: $TODAY_COUNT operations"

if [ "$TOTAL_LINES" -gt 0 ]; then
    echo "Most common file type: $(cut -d'|' -f3 "$METRICS_FILE" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')"
    echo "Most active file: $(cut -d'|' -f3 "$METRICS_FILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')"
fi