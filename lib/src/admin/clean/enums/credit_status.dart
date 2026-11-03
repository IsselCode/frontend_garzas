enum CreditStatus {
  pending('Pendientes'),
  paid('Pagados'),
  all('Todos');

  const CreditStatus(this.label);
  final String label;
}
