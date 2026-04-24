import { colorForIndex } from '../src/chat/categoryColors';

describe('colorForIndex', () => {
  it('cycles through the palette', () => {
    expect(colorForIndex(0)).toBe(colorForIndex(15));
    expect(colorForIndex(1)).toBe(colorForIndex(16));
  });

  it('handles negative indexes defensively', () => {
    expect(typeof colorForIndex(-1)).toBe('number');
  });
});
