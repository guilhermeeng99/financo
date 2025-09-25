enum AccountType {
  checking('checking'),
  creditCard('creditCard');

  const AccountType(this.value);
  final String value;
}

enum AccountIconType {
  none('none'),
  nubank('nubank');

  const AccountIconType(this.value);
  final String value;
}

enum CurrencyType {
  brl('BRL'),
  usd('USD'),
  eur('EUR');

  const CurrencyType(this.value);
  final String value;
}
