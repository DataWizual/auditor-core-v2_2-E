#!/bin/bash
# Auditor Core Professional - Smart Admin Provisioning (V2)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🛡️ Auditor Core Professional: System Setup${NC}"

# --- 1. TERMS OF USE ---
echo "------------------------------------------------------------"
echo "🛡️  DATAWIZUAL SECURITY GATE: INSTALLATION"
echo "------------------------------------------------------------"
echo "IMPORTANT: This installation is subject to the Terms of Use"
echo "defined in the TERMS_OF_USE.md file."
echo ""
echo "By typing YES, you acknowledge that:"
echo "1. Software is provided 'AS-IS' (No Financial Liability)."
echo "2. You are responsible for all security decisions & overrides."
echo "3. Machine ID submission constitutes full acceptance of Terms."
echo "------------------------------------------------------------"

read -p "Type YES to accept terms and proceed: " confirm

if [ "$confirm" != "YES" ]; then
    echo "❌ Installation aborted. Terms of Use must be accepted."
    exit 1
fi

# --- 2. ENVIRONMENT CONFIGURATION ---
if [ ! -f .env ]; then
    echo -e "${YELLOW}Configuring environment...${NC}"

    if [ ! -f .env.example ]; then
        echo -e "${RED}Error: .env.example not found.${NC}"
        exit 1
    fi

    cp .env.example .env

    read -p "Enter AUDITOR_LICENSE_KEY: " license_key
    read -s -p "Enter DB_PASSWORD: " db_password
    echo ""
    read -s -p "Enter Google Gemini API Key: " gemini_key
    echo ""
    read -s -p "Enter Groq API Key (fallback AI, press Enter to skip): " groq_key
    echo ""

    python3 -c "
import sys
content = open('.env').read()
content = content.replace('YOUR_LICENSE_KEY_HERE', sys.argv[1])
open('.env', 'w').write(content)
" "$license_key"

    python3 -c "
import sys
content = open('.env').read()
content = content.replace('SET_STRONG_PASSWORD_HERE', sys.argv[1])
open('.env', 'w').write(content)
" "$db_password"

    python3 -c "
import sys
content = open('.env').read()
content = content.replace('YOUR_GOOGLE_API_KEY_HERE', sys.argv[1])
open('.env', 'w').write(content)
" "$gemini_key"

    if [ -n "$groq_key" ]; then
        python3 -c "
import sys
content = open('.env').read()
content = content.replace('YOUR_GROQ_API_KEY_HERE', sys.argv[1])
open('.env', 'w').write(content)
" "$groq_key"
    fi

    if grep -q "YOUR_LICENSE_KEY_HERE\|SET_STRONG_PASSWORD_HERE\|YOUR_GOOGLE_API_KEY_HERE" .env; then
        echo -e "${RED}Error: .env still contains unfilled placeholders. Check .env.example.${NC}"
        rm .env
        exit 1
    fi

    chmod 600 .env
    echo -e "${GREEN}✅ .env configured.${NC}"
fi

# --- 3. INFRASTRUCTURE CHECK ---
echo -e "\n${BLUE}Checking Infrastructure...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running.${NC}"
    exit 1
fi

docker-compose up -d --wait

# --- 4. PYTHON VIRTUAL ENVIRONMENT ---
if [ -d "venv" ]; then
    echo -e "${GREEN}Existing virtual environment found.${NC}"
else
    echo -e "${BLUE}Creating new Python Virtual Environment...${NC}"
    python3 -m venv venv
fi

source venv/bin/activate

# --- 5. DEPENDENCIES ---
echo -e "${BLUE}Syncing dependencies...${NC}"
pip install -q --upgrade pip
if [ -f "requirements.txt" ]; then
    pip install -q -r requirements.txt
fi

chmod +x audit
echo -e "\n${GREEN}✅ READY TO GO!${NC}"
echo -e "Usage: ${YELLOW}./audit <target_path_or_link>${NC}"
echo "--------------------------------------------------"

if ./audit --version 2>/dev/null; then
    echo -e "${GREEN}✅ Verification passed.${NC}"
else
    echo -e "${YELLOW}⚠️ Version check failed — setup complete but check dependencies.${NC}"
fi