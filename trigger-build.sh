#!/bin/bash
# Trigger GitHub Actions Android build via repository dispatch

set -e

REPO_OWNER="a96900001-eng"
REPO_NAME="ChatAI"
BRANCH="android/capacitor-androidize"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Install from: https://cli.github.com"
    exit 1
fi

echo "🚀 Triggering GitHub Actions build..."
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "Branch: $BRANCH"
echo ""

# Trigger workflow via GitHub CLI
gh workflow run android-build.yml \
  --repo $REPO_OWNER/$REPO_NAME \
  --ref $BRANCH

echo "✅ Build triggered!"
echo ""
echo "📊 Check build status:"
echo "   https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo ""
echo "⏱️  Builds typically complete in 10-15 minutes"
echo ""
echo "📥 Download APK:"
echo "   1. Go to Actions tab"
echo "   2. Click latest workflow run"
echo "   3. Download 'chatai-debug-apk' artifact"
