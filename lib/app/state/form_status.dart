/// Lifecycle of a form-submission flow, shared by every form cubit
/// (transactions, accounts, categories, investments) so a feature's
/// presentation layer never has to import another feature's cubit just to
/// reach this enum.
enum FormStatus { initial, submitting, success, failure }
