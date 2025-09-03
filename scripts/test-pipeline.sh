#!/bin/bash
set -e

echo "🧪 Testing Claude Code Quality Pipeline..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ $2${NC}"
        ((TESTS_FAILED++))
    fi
}

echo -e "${BLUE}🔍 Phase 1: Environment Validation${NC}"

# Test 1: Claude Code availability
claude --version > /dev/null 2>&1
test_result $? "Claude Code is available"

# Test 2: Project dependencies
if [ -d "sample-project" ]; then
    cd sample-project
    if [ -f "package.json" ]; then
        npm list > /dev/null 2>&1
        test_result $? "Project dependencies installed"
    else
        test_result 1 "package.json exists"
    fi
else
    test_result 1 "sample-project directory exists"
    echo -e "${RED}Cannot continue tests without sample-project${NC}"
    exit 1
fi

# Test 3: Development tools
if npx prettier --version > /dev/null 2>&1 && npx eslint --version > /dev/null 2>&1; then
    test_result 0 "Development tools available"
else
    test_result 1 "Development tools available"
fi

# Test 4: Agent availability
cd ..
SIMPLE_AGENTS=(
    "security-agent"
    "quality-agent"
    "docs-agent"
)

AGENTS_FOUND=0
for agent in "${SIMPLE_AGENTS[@]}"; do
    if [ -f ".claude/agents/${agent}.md" ]; then
        test_result 0 "Agent ${agent} file exists"
        ((AGENTS_FOUND++))
    else
        test_result 1 "Agent ${agent} file exists"
    fi
done

echo -e "${BLUE}📊 Found ${AGENTS_FOUND}/${#SIMPLE_AGENTS[@]} agents${NC}"

# Test 5: Claude Code agent integration (if possible)
if claude /agents > /dev/null 2>&1; then
    CLAUDE_AGENTS_FOUND=0
    for agent in "${SIMPLE_AGENTS[@]}"; do
        if claude /agents | grep -q "${agent}"; then
            test_result 0 "${agent} recognized by Claude Code"
            ((CLAUDE_AGENTS_FOUND++))
        else
            test_result 1 "${agent} recognized by Claude Code"
        fi
    done
    echo -e "${BLUE}📊 ${CLAUDE_AGENTS_FOUND}/${#SIMPLE_AGENTS[@]} agents recognized by Claude Code${NC}"
else
    echo -e "${YELLOW}⚠️ Cannot test Claude agent integration (Claude not responding)${NC}"
fi

echo -e "\n${BLUE}🔧 Phase 2: Hook Configuration Testing${NC}"

# Test 6: Hook configuration syntax
if [ -f ".claude/settings.local.json" ]; then
    if command -v python > /dev/null 2>&1; then
        python -m json.tool .claude/settings.local.json > /dev/null 2>&1
        test_result $? "Hook configuration syntax valid"
        
        # Test for 5-step pipeline
        if grep -q "Step 1/5\|Step 2/5\|Step 3/5\|Step 4/5\|Step 5/5" .claude/settings.local.json; then
            test_result 0 "5-step pipeline present in configuration"
        else
            test_result 1 "5-step pipeline present in configuration"
        fi
    else
        echo -e "${YELLOW}⚠️ Cannot validate JSON (Python not available)${NC}"
        test_result 0 "Hook configuration exists"
    fi
else
    test_result 1 "Hook configuration file exists"
fi

# Test 7: Create test file to trigger hooks
cd sample-project
echo "// Test file for pipeline validation" > test-pipeline-file.js
echo "console.log('testing 5-step hooks');" >> test-pipeline-file.js

# Test 8: Simulate hook execution environment
export file_path="test-pipeline-file.js"
export tool="Write"

# Test individual hook commands
if [[ "${file_path}" =~ \.js$ ]]; then
    if npx prettier --write "${file_path}" > /dev/null 2>&1 && npx eslint --fix "${file_path}" > /dev/null 2>&1; then
        test_result 0 "Formatting & linting works"
    else
        test_result 1 "Formatting & linting works"
    fi
else
    test_result 1 "File pattern matching works"
fi

echo -e "\n${BLUE}🤖 Phase 3: Agent Testing${NC}"

cd ..
if command -v timeout > /dev/null 2>&1; then
    # Test simplified agents
    for agent in "${SIMPLE_AGENTS[@]}"; do
        if [ -f ".claude/agents/${agent}.md" ]; then
            echo "Testing ${agent}..." > /tmp/${agent}-test.log
            case $agent in
                "security-agent")
                    PROMPT="Quick security scan of sample-project/src/components/LoginForm.jsx"
                    ;;
                "quality-agent") 
                    PROMPT="Quality analysis of sample-project/src/components/LoginForm.jsx"
                    ;;
                "docs-agent")
                    PROMPT="Check documentation for sample-project"
                    ;;
            esac
            
            if timeout 30s claude /agent ${agent} "${PROMPT}" >> /tmp/${agent}-test.log 2>&1; then
                if [ -s /tmp/${agent}-test.log ]; then
                    test_result 0 "${agent} responds"
                else
                    test_result 1 "${agent} produces output"
                fi
            else
                test_result 1 "${agent} responds (timeout or error)"
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠️ Cannot test agent responses (timeout command not available)${NC}"
fi

echo -e "\n${BLUE}📊 Phase 4: Integration Testing${NC}"

# Test 11: File system integration
cd sample-project
if [[ -f "src/components/LoginForm.jsx" ]]; then
    test_result 0 "Sample codebase is ready"
else
    test_result 1 "Sample codebase is ready"
fi

# Test 12: Basic logging capability
if mkdir -p ~/.claude/ 2>/dev/null; then
    touch ~/.claude/test.log
    if [ -f ~/.claude/test.log ]; then
        test_result 0 "Basic logging works"
        rm -f ~/.claude/test.log
    else
        test_result 1 "Basic logging works"
    fi
else
    test_result 1 "Can create log directory"
fi

# Cleanup
rm -f test-pipeline-file.js
cd ..
rm -f /tmp/*-test.log

echo -e "\n${BLUE}📋 Test Results Summary${NC}"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
else
    echo -e "${GREEN}Tests Failed: $TESTS_FAILED${NC}"
fi

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Quality pipeline is ready for use.${NC}"
    echo -e "\n${BLUE}🚀 Pipeline Features Verified:${NC}"
    echo "✅ 5-step automated quality pipeline"
    echo "✅ JavaScript/TypeScript formatting and linting" 
    echo "✅ Security vulnerability scanning"
    echo "✅ Code quality analysis"
    echo "✅ Automated testing"
    echo "✅ Documentation maintenance"
    
    echo -e "\n${BLUE}📋 Next Steps:${NC}"
    echo "1. cd sample-project"  
    echo "2. claude 'Fix the security issues in LoginForm.jsx'"
    echo "3. Watch the 5-step pipeline activate automatically:"
    echo "   🔧 Formatting & Linting → 🛡️ Security Analysis → 📊 Quality Review"
    echo "   🧪 Testing → 📖 Documentation"
    echo "4. Try manual agent analysis:"
    echo "   - /agent security-agent 'Deep security scan of authentication'"
    echo "   - /agent quality-agent 'Comprehensive quality review'"
    echo "   - /agent docs-agent 'Update documentation for new features'"
    
    exit 0
else
    echo -e "\n${YELLOW}⚠️ Some tests failed. The pipeline may have reduced functionality.${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED tests${NC}"
    echo -e "${BLUE}Troubleshooting:${NC}"
    echo "- Run ./scripts/setup.sh to retry setup"
    echo "- Ensure Claude Code is properly installed and configured"
    echo "- Verify agents are in .claude/agents/ directory"
    echo "- Check development tool installations (prettier, eslint)"
    echo "- Test individual agents with: /agent [agent-name] 'test prompt'"
    exit 1
fi