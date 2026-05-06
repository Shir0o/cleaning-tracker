#!/usr/bin/env bash
# One-shot setup for Firebase Test Lab + Workload Identity Federation
# auth from a GitHub Actions workflow.
#
# Usage:
#   PROJECT_ID=your-gcp-project-id REPO=owner/repo ./scripts/setup-firebase-testlab.sh
#
# Defaults if unset:
#   REPO=Shir0o/cleaning-tracker
#
# Prerequisites (one-time, on your machine):
#   1. gcloud CLI installed and authenticated:  gcloud auth login
#   2. gh CLI installed and authenticated:      gh auth login
#   3. You have Owner (or equivalent) on the GCP project.
#
# This script is idempotent — re-running it is safe; existing resources
# are skipped rather than recreated.

set -euo pipefail

PROJECT_ID="${PROJECT_ID:?Set PROJECT_ID to your GCP project ID, e.g. PROJECT_ID=cleaning-tracker-489919}"
REPO="${REPO:-Shir0o/cleaning-tracker}"
SA_NAME="gh-actions"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
POOL_ID="github-pool"
PROVIDER_ID="github-provider"
RESULTS_BUCKET="${RESULTS_BUCKET:-cleaning-tracker-testlab-results}"
BUCKET_LOCATION="${BUCKET_LOCATION:-us-central1}"

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

echo "==> Granting roles to ${SA_EMAIL}"
# - firebase.admin: required for Test Lab access; the narrower
#   firebase.qualityAdmin did not include cloudtestservice perms on a
#   recently-linked Firebase project (observed empty includedPermissions).
# - serviceusage.serviceUsageConsumer: lets the SA consume project API
#   quota; without it Cloud Testing returns "Not authorized for project".
# - storage.objectAdmin: Test Lab uploads the app+test APKs to a managed
#   GCS bucket; without it the upload fails with storage.objects.create
#   permission denied.
for role in \
  roles/firebase.admin \
  roles/serviceusage.serviceUsageConsumer \
  roles/storage.objectAdmin; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="${role}" \
    --condition=None >/dev/null
done

REPO_OWNER="${REPO%%/*}"

echo "==> Ensuring Workload Identity Pool '${POOL_ID}' exists"
if ! gcloud iam workload-identity-pools describe "${POOL_ID}" \
  --location="global" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools create "${POOL_ID}" \
    --location="global" \
    --display-name="GitHub Actions Pool" \
    --project="${PROJECT_ID}"
else
  echo "    already exists"
fi

POOL_NAME=$(gcloud iam workload-identity-pools describe "${POOL_ID}" \
  --location="global" \
  --project="${PROJECT_ID}" \
  --format="value(name)")

echo "==> Ensuring OIDC provider '${PROVIDER_ID}' exists on the pool"
# Google requires GitHub providers to bind to a specific repository_owner
# (Jan 2025 security hardening) to prevent same-name impersonation.
if ! gcloud iam workload-identity-pools providers describe "${PROVIDER_ID}" \
  --location="global" --workload-identity-pool="${POOL_ID}" \
  --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_ID}" \
    --location="global" \
    --workload-identity-pool="${POOL_ID}" \
    --display-name="GitHub OIDC" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner,attribute.actor=assertion.actor" \
    --attribute-condition="assertion.repository_owner=='${REPO_OWNER}' && assertion.repository=='${REPO}'" \
    --project="${PROJECT_ID}"
else
  echo "    already exists"
fi

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

echo "==> Ensuring Test Lab results bucket gs://${RESULTS_BUCKET} exists"
# Test Lab's auto-provisioned bucket lives in a Google-owned project we
# can't grant IAM on, so we use a results bucket we control instead.
if ! gcloud storage buckets describe "gs://${RESULTS_BUCKET}" \
  --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud storage buckets create "gs://${RESULTS_BUCKET}" \
    --project="${PROJECT_ID}" \
    --location="${BUCKET_LOCATION}" \
    --uniform-bucket-level-access
else
  echo "    already exists"
fi

echo "==> Granting ${SA_EMAIL} write access to the results bucket"
gcloud storage buckets add-iam-policy-binding \
  "gs://${RESULTS_BUCKET}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.objectAdmin" >/dev/null

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
