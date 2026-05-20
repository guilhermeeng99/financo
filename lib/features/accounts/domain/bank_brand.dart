import 'package:financo/core/utils/string_normalize.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';

/// Visual + textual identity of a bank.
///
/// `color` is the brand color (ARGB int). `abbreviation` is what the
/// avatar prints — 2–4 chars, kept short so it reads at 40px. Every
/// bank renders the same way (coloured circle + abbreviation), which
/// avoids needing per-bank logo assets.
class BankBrand {
  const BankBrand({
    required this.label,
    required this.abbreviation,
    required this.color,
  });

  final String label;
  final String abbreviation;
  final int color;

  /// Source-of-truth registry. Every [BankType] must have an entry —
  /// the unit test "every BankType has a brand" guards this.
  static const _registry = <BankType, BankBrand>{
    BankType.nubank: BankBrand(
      label: 'Nubank',
      abbreviation: 'Nu',
      color: 0xFF820AD1,
    ),
    BankType.nuInvest: BankBrand(
      label: 'NuInvest',
      abbreviation: 'Nui',
      color: 0xFF4F1389,
    ),
    BankType.itau: BankBrand(
      label: 'Itaú',
      abbreviation: 'Itaú',
      color: 0xFFEC7000,
    ),
    BankType.bradesco: BankBrand(
      label: 'Bradesco',
      abbreviation: 'Bra',
      color: 0xFFCC092F,
    ),
    BankType.bancoDoBrasil: BankBrand(
      label: 'Banco do Brasil',
      abbreviation: 'BB',
      color: 0xFFFAE128,
    ),
    BankType.santander: BankBrand(
      label: 'Santander',
      abbreviation: 'San',
      color: 0xFFEC0000,
    ),
    BankType.caixa: BankBrand(
      label: 'Caixa',
      abbreviation: 'CEF',
      color: 0xFF0070AF,
    ),
    BankType.inter: BankBrand(
      label: 'Inter',
      abbreviation: 'Int',
      color: 0xFFFF7A00,
    ),
    BankType.c6: BankBrand(
      label: 'C6 Bank',
      abbreviation: 'C6',
      color: 0xFF1C1C1C,
    ),
    BankType.btg: BankBrand(
      label: 'BTG Pactual',
      abbreviation: 'BTG',
      color: 0xFF003366,
    ),
    BankType.sicredi: BankBrand(
      label: 'Sicredi',
      abbreviation: 'Sic',
      color: 0xFF3BAA35,
    ),
    BankType.sicoob: BankBrand(
      label: 'Sicoob',
      abbreviation: 'Sco',
      color: 0xFF0F543F,
    ),
    BankType.picpay: BankBrand(
      label: 'PicPay',
      abbreviation: 'Pic',
      color: 0xFF21C25E,
    ),
    BankType.mercadoPago: BankBrand(
      label: 'Mercado Pago',
      abbreviation: 'MP',
      color: 0xFF00B1EA,
    ),
    BankType.pan: BankBrand(
      label: 'Banco Pan',
      abbreviation: 'Pan',
      color: 0xFF005DAA,
    ),
    BankType.original: BankBrand(
      label: 'Original',
      abbreviation: 'Ori',
      color: 0xFF00C75A,
    ),
    BankType.safra: BankBrand(
      label: 'Safra',
      abbreviation: 'Saf',
      color: 0xFF1E3A8A,
    ),
    BankType.xp: BankBrand(
      label: 'XP',
      abbreviation: 'XP',
      color: 0xFFFFC600,
    ),
    BankType.next: BankBrand(
      label: 'Next',
      abbreviation: 'Nx',
      color: 0xFF00FF7F,
    ),
    BankType.will: BankBrand(
      label: 'Will Bank',
      abbreviation: 'Will',
      color: 0xFF54E76C,
    ),
    BankType.neon: BankBrand(
      label: 'Neon',
      abbreviation: 'Neon',
      color: 0xFFFFFC00,
    ),
    BankType.avenue: BankBrand(
      label: 'Avenue',
      abbreviation: 'Av',
      color: 0xFF002820,
    ),
    BankType.others: BankBrand(
      label: 'Others',
      abbreviation: '',
      color: 0xFF607D8B,
    ),
  };

  /// Returns the brand for [type]. Throws if the registry is missing an
  /// entry — the unit test "every BankType has a brand" prevents this in
  /// practice.
  static BankBrand of(BankType type) {
    final brand = _registry[type];
    if (brand == null) {
      throw StateError('No BankBrand registered for $type');
    }
    return brand;
  }

  /// Resolves a free-text bank label (CSV cell, AI tool call, etc.) to a
  /// known [BankType]. Returns `null` if no alias matches — callers
  /// should default to [BankType.others] in that case.
  ///
  /// Matching is case-insensitive and accent-insensitive: "ITAÚ", "itau"
  /// and "Itaú" all resolve to [BankType.itau]. We compare against both
  /// the `label` and an explicit alias list so common short forms ("nu"
  /// for Nubank, "bb" for Banco do Brasil) work as well.
  static BankType? resolveAlias(String input) {
    final needle = normalizeForMatch(input);
    if (needle.isEmpty) return null;
    final exact = _aliasIndex[needle];
    if (exact != null) return exact;
    // Word-level fallback so "Banco Itau" still resolves to itau without
    // letting "xpto-bank" substring-match "xp".
    for (final word in needle.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final hit = _aliasIndex[word];
      if (hit != null) return hit;
    }
    return null;
  }

  static final Map<String, BankType> _aliasIndex = _buildAliasIndex();

  static Map<String, BankType> _buildAliasIndex() {
    final map = <String, BankType>{};
    for (final entry in _registry.entries) {
      map[normalizeForMatch(entry.value.label)] = entry.key;
      map[normalizeForMatch(entry.key.name)] = entry.key;
    }
    // Hand-curated short aliases users actually type / AI tools emit.
    const extras = <String, BankType>{
      'nu': BankType.nubank,
      'nuinvest': BankType.nuInvest,
      'nu invest': BankType.nuInvest,
      'easynvest': BankType.nuInvest,
      'bb': BankType.bancoDoBrasil,
      'banco do brasil': BankType.bancoDoBrasil,
      'caixa economica': BankType.caixa,
      'caixa economica federal': BankType.caixa,
      'cef': BankType.caixa,
      'banco itau': BankType.itau,
      'itau unibanco': BankType.itau,
      'banco bradesco': BankType.bradesco,
      'banco santander': BankType.santander,
      'banco inter': BankType.inter,
      'c6': BankType.c6,
      'btg': BankType.btg,
      'btg pactual': BankType.btg,
      'banco original': BankType.original,
      'banco safra': BankType.safra,
      'mercadopago': BankType.mercadoPago,
      'mp': BankType.mercadoPago,
      'pic pay': BankType.picpay,
      'will bank': BankType.will,
      'neon pagamentos': BankType.neon,
      'banco neon': BankType.neon,
      'avenue securities': BankType.avenue,
      'avenue corretora': BankType.avenue,
    };
    for (final e in extras.entries) {
      map[e.key] = e.value;
    }
    return map;
  }
}
