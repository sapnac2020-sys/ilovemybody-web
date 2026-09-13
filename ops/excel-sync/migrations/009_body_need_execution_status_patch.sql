-- Align persisted body-need execution states with the governed execution engine.
ALTER TABLE ilmb_body_need_run
  MODIFY COLUMN execution_status ENUM(
    'READY',
    'BLOCKED_MISSING_INPUT',
    'BLOCKED_UNVERIFIED_FORMULA',
    'BLOCKED_UNVERIFIED_TARGET',
    'BLOCKED_UNIT_MISMATCH',
    'COMPUTED',
    'ERROR'
  ) NOT NULL;
