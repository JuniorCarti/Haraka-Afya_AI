# Security Guidelines

## Never Commit These Files:
- `.env` files with API keys
- `serviceAccountKey.json` Firebase keys
- `google-services.json` Android configs
- `node_modules/` folders

## Pre-commit Check:
Always run before committing:
```bash
git status | grep -E '(\.env|serviceAccountKey|node_modules)'