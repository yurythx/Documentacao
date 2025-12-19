CREATE INDEX IF NOT EXISTS idx_contacts_phone ON contacts (phone);
CREATE INDEX IF NOT EXISTS idx_contacts_current_step ON contacts (current_step);
CREATE INDEX IF NOT EXISTS idx_messages_contact_created_at ON messages (contact_phone, created_at);
