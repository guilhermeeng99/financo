import { _resetDedupeForTests, isDuplicate } from '../src/whatsapp/dedupe';

describe('isDuplicate', () => {
  beforeEach(() => _resetDedupeForTests());

  it('returns false on first sight and true afterwards', () => {
    expect(isDuplicate('msg-1')).toBe(false);
    expect(isDuplicate('msg-1')).toBe(true);
  });

  it('tracks distinct ids independently', () => {
    expect(isDuplicate('msg-a')).toBe(false);
    expect(isDuplicate('msg-b')).toBe(false);
    expect(isDuplicate('msg-a')).toBe(true);
    expect(isDuplicate('msg-b')).toBe(true);
  });
});
