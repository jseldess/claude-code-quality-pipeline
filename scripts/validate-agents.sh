#!/bin/bash

echo "🤖 Validating Claude Code Agents..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

validate_agent() {
    local agent_name=$1
    local agent_file=".claude/agents/${agent_name}.md"
    
    echo -e "${BLUE}Checking $agent_name...${NC}"
    
    # Check file exists
    if [[ ! -f "$agent_file" ]]; then
        echo -e "${RED}❌ Agent file not found: $agent_file${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Agent file exists${NC}"
    
    # Check frontmatter
    if ! head -10 "$agent_file" | grep -q "name: $agent_name"; then
        echo -e "${RED}❌ Agent name mismatch in frontmatter${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Agent name correct in frontmatter${NC}"
    
    # Check tools specification
    if ! head -10 "$agent_file" | grep -q "tools:"; then
        echo -e "${RED}❌ Missing tools specification${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Tools specification found${NC}"
    
    # Check description
    if ! head -10 "$agent_file" | grep -q "description:"; then
        echo -e "${RED}❌ Missing description${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Description found${NC}"
    
    # Check agent content length (should be substantial)
    local line_count=$(wc -l < "$agent_file")
    if [ "$line_count" -lt 50 ]; then
        echo -e "${YELLOW}⚠️ Agent file seems short ($line_count lines), may lack detail${NC}"
    else
        echo -e "${GREEN}✅ Agent file has substantial content ($line_count lines)${NC}"
    fi
    
    # Check for common sections
    if grep -q "## " "$agent_file"; then
        echo -e "${GREEN}✅ Agent has structured sections${NC}"
    else
        echo -e "${YELLOW}⚠️ Agent may lack structured sections${NC}"
    fi
    
    # Check if agent is recognized by Claude (if possible)
    if command -v claude > /dev/null 2>&1; then
        if claude /agents 2>/dev/null | grep -q "$agent_name"; then
            echo -e "${GREEN}✅ $agent_name is recognized by Claude${NC}"
        else
            echo -e "${YELLOW}⚠️ $agent_name may not be recognized by Claude${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Cannot test Claude recognition (Claude not available)${NC}"
    fi
    
    echo ""
    return 0
}

# Validate each agent
AGENTS=("code-quality-enforcer" "review-coordinator" "security-scanner")
VALIDATED=0
FAILED=0

for agent in "${AGENTS[@]}"; do
    if validate_agent "$agent"; then
        ((VALIDATED++))
    else
        ((FAILED++))
    fi
done

echo -e "${BLUE}📊 Validation Summary${NC}"
echo -e "${GREEN}Agents validated: $VALIDATED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Agents failed: $FAILED${NC}"
else
    echo -e "${GREEN}Agents failed: $FAILED${NC}"
fi

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ All agents validated successfully${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️ Some agent validation issues found${NC}"
    echo "Check the agent files in .claude/agents/ and fix any issues mentioned above."
    exit 1
fi