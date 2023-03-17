return {
  postgres = {
    up = [[
      DO $$
      BEGIN
        ALTER TABLE IF EXISTS ONLY myauth_credentials ADD tags TEXT[];
      EXCEPTION WHEN DUPLICATE_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;

      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS keyauth_tags_idex_tags_idx ON myauth_credentials USING GIN(tags);
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;

      DROP TRIGGER IF EXISTS keyauth_sync_tags_trigger ON myauth_credentials;

      DO $$
      BEGIN
        CREATE TRIGGER keyauth_sync_tags_trigger
        AFTER INSERT OR UPDATE OF tags OR DELETE ON myauth_credentials
        FOR EACH ROW
        EXECUTE PROCEDURE sync_tags();
      EXCEPTION WHEN UNDEFINED_COLUMN OR UNDEFINED_TABLE THEN
        -- Do nothing, accept existing state
      END$$;

      DO $$
      BEGIN
        ALTER TABLE IF EXISTS ONLY "myauth_credentials" ADD "ttl" TIMESTAMP WITH TIME ZONE;
      EXCEPTION WHEN DUPLICATE_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;

      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS myauth_credentials_ttl_idx ON myauth_credentials (ttl);
      EXCEPTION WHEN UNDEFINED_TABLE THEN
        -- Do nothing, accept existing state
      END$$;

    ]],
  },
  cassandra = {
    up = [[
      ALTER TABLE myauth_credentials ADD tags set<text>;
    ]],
  }
}
