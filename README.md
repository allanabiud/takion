# Takion

Takion is a Flutter comic client that now uses Supabase for app authentication
and user profiles, while Metron is handled as an optional connected account for
comic data access.

## Setup

### 1) Configure Supabase

Create a Supabase project and run the SQL script in:

- `tool/supabase_profiles.sql`

This creates the `profiles` table and row-level-security policies used by the app.

### 2) Run with environment values

The app requires these `dart-define` values at runtime:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Example:

```bash
flutter run \
	--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## Auth model

- App login/signup: Supabase email + password.
- Profiles: stored in Supabase `profiles` table.
- Metron credentials: stored separately as an optional connected account in app settings.
