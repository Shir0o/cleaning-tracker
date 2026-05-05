#!/usr/bin/env bash
# One-shot setup for Firebase Test Lab + Workload Identity Federation
# auth from this repo's GitHub Actions.
#
# Prerequisites (one-time, on your machine):
#   1. gcloud CLI installed and authenticated:  gcloud auth login
#   2. gh CLI installed and authenticated:      gh auth login
#   3. You have Owner (or equivalent) on the GCP project.
#
# This script is idempotent — re-running it is safe; existing resources
# are skipped rather than recreated.

set -euo pipefail

PROJECT_ID="cleaning-tracker-489919"
REPO="Shir0o/cleaning-tracker"
SA_NAME="gh-actions"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
POOL_ID="github-pool"
PROVIDER_ID="github-provider"

echo "==> Setting active project to ${PROJECT_ID}"
gcloud config set project "${PROJECT_ID}" >/dev/null

echo "==> Enabling required APIs (Cloud Testing, Tool Results, IAM Credentials, Sts)"
gcloud services enable \
  testing.googleapis.com \
  toolresults.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  --project="${PROJECT_ID}"

echo "==> Creating service account ${SA_EMAIL} (skip if exists)"
gcloud iam service-accounts create "${SA_NAME}" \
  --display-name="GitHub Actions — Firebase Test Lab" \
  --project="${PROJECT_ID}" 2>/dev/null || echo "    already exists"

echo "==> Granting roles/firebase.testAdmin to ${SA_EMAIL}"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/firebase.testAdmin" \
  --condition=None >/dev/null

echo "==> Creating Workload Identity Pool '${POOL_ID}' (skip if exists)"
gcloud iam workload-identity-pools create "${POOL_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool" \
  --project="${PROJECT_ID}" 2>/dev/null || echo "    already exists"

POOL_NAME=$(gcloud iam workload-identity-pools describe "${POOL_ID}" \
  --location="global" \
  --project="${PROJECT_ID}" \
  --format="value(name)")

echo "==> Creating OIDC provider '${PROVIDER_ID}' on the pool (skip if exists)"
gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_ID}" \
  --location="global" \
  --workload-identity-pool="${POOL_ID}" \
  --display-name="GitHub OIDC" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
  --attribute-condition="assertion.repository=='${REPO}'" \
  --project="${PROJECT_ID}" 2>/dev/null || echo "    already exists"

PROVIDER_NAME=$(gcloud iam workload-identity-pools providers describe "${PROVIDER_ID}" \
  --location="global" \
  --workload-identity-pool="${POOL_ID}" \
  --project="${PROJECT_ID}" \
  --format="value(name)")

echo "==> Allowing the GitHub repo to impersonate ${SA_EMAIL}"
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${POOL_NAME}/attribute.repository/${REPO}" \
  --project="${PROJECT_ID}" >/dev/null

echo "==> Pushing secrets to GitHub repo ${REPO}"
gh secret set WIF_PROVIDER --body "${PROVIDER_NAME}" --repo "${REPO}"
gh secret set WIF_SERVICE_ACCOUNT --body "${SA_EMAIL}" --repo "${REPO}"

echo
echo "Setup complete."
echo "  WIF_PROVIDER        = ${PROVIDER_NAME}"
echo "  WIF_SERVICE_ACCOUNT = ${SA_EMAIL}"
echo
echo "Open a new PR (or re-run CI on PR #19) to verify the integration"
echo "tests job authenticates and runs on Firebase Test Lab."
