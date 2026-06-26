#!/bin/bash

# Setup colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Refreshing Lloyds Banking Assistant environment settings...${NC}"

# 1. Fetch Cloud Run URL dynamically or fallback to hardcoded
echo -e "${BLUE}📡 Retrieving Cloud Run Service URL...${NC}"
SERVICE_NAME="agent-service"
REGION="us-central1"

RUN_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)' 2>/dev/null)

if [ -z "$RUN_URL" ]; then
  echo -e "${YELLOW}⚠️ Could not retrieve URL dynamically. Falling back to default URL...${NC}"
  RUN_URL="https://agent-service-1006690832279.us-central1.run.app"
else
  echo -e "${GREEN}✔ Service URL found: $RUN_URL${NC}"
fi

# Append endpoint route
API_URL="${RUN_URL}/api/chat"

# 2. Fetch gcloud identity token
echo -e "${BLUE}🔐 Fetching active gcloud identity token...${NC}"
IDENTITY_TOKEN=$(gcloud auth print-identity-token 2>/dev/null)

if [ -z "$IDENTITY_TOKEN" ]; then
  echo -e "${RED}❌ Failed to fetch gcloud token. Are you logged in? Run 'gcloud auth login' first.${NC}"
else
  echo -e "${GREEN}✔ Successfully retrieved active identity token!${NC}"
fi

# 3. Write/Update .env file
echo -e "${BLUE}📝 Generating .env file...${NC}"
cat <<EOF > .env
API_URL=$API_URL
API_KEY=$IDENTITY_TOKEN
EOF

echo -e "${GREEN}✔ .env file updated successfully!${NC}"
echo -e "   - API_URL: $API_URL"
if [ ! -z "$IDENTITY_TOKEN" ]; then
  echo -e "   - API_KEY: [Successfully written JWT token]"
else
  echo -e "   - API_KEY: [Empty]"
fi

echo -e "${YELLOW}👉 Run the app using:${NC} ${GREEN}flutter run --dart-define-from-file=.env${NC}"
